#!/usr/bin/env python3
"""RSQ Wheel: build the ON-GUN CARD voxels (Project Wheel, items 1-5) from Ermac's Force Unleashed holo art.

    python3 tools/gen_cards.py [--art <folder with ammo_bg*.png, digit_*.png, ammo.png ...>]

Writes into the Wheel folder:  voxels/wk*.kvx, VOXELDEF.txt (between the WRCARD markers),
sprites/wk/*.png (1x1 placeholders so the sprite names exist), zscript/wheel/wr_q_card_states.zs.

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
degree, about 0.11 cm at the card), which is how wr_card_side / wr_card_up move it without new voxels.

Ermac's art: CREDITS.txt. Run again after changing the art or the layout; the output is deterministic.
"""
import argparse, os, struct, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
WHEEL = os.path.dirname(HERE)

# ---- the layout, in model centimetres -----------------------------------------------------------
CARD = (5.0, -24.0, 8.0)      # rear display centre: beside the stock on the inboard side, facing you while you aim
                              # (rig: centred over the stock, BD22 VR's stock hid it; clear of the sight line)
PANEL_W, PANEL_H, PANEL_S = 64, 40, 0.125        # 8 x 5 cm
FRONT = 0.20                                      # glyphs stand this far in front of the panel
LABEL_S = 0.0625                                  # Ermac's 88x12 labels: 5.5 x 0.75 cm
BIG_S, SMALL_S = 0.15, 0.08                       # 12 px digits: 1.8 cm and 0.96 cm
# slot centres relative to the card centre (X + = player's left, Z + = up)
LABEL_AT = (1.0, 0.0, 1.75)
BIG_AT = [(2.6, 0.0, -0.15), (0.75, 0.0, -0.15), (-1.1, 0.0, -0.15)]
SMALL_AT = [(-1.65, 0.0, -1.6), (-2.6, 0.0, -1.6), (-3.55, 0.0, -1.6)]
LABELS = ['ammo', 'magazine', 'chamber']
GLYPHS = [str(d) for d in range(10)] + ['o', 'g', 'd']   # digit_o / digit_g / digit_d as Ermac drew them


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


def card_piece(png, w, h, scale, local, mirror, out, alpha_cut=60):
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
    X, Y, Z = CARD[0] + lx, CARD[1] + ly, CARD[2] + lz
    piv = (w / 2.0 + X / scale, 0.5 + Y / scale, h / 2.0 + Z / scale)
    write_kvx(out, vox, (w, 1, h), piv, pal)
    return len(vox)


def add(a, b): return tuple(x + y for x, y in zip(a, b))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--art', default=os.path.join(HERE, 'card_art'))
    a = ap.parse_args()
    art = a.art
    vdir = os.path.join(WHEEL, 'voxels'); os.makedirs(vdir, exist_ok=True)
    sdir = os.path.join(WHEEL, 'sprites', 'wk'); os.makedirs(sdir, exist_ok=True)
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
    for m in (0, 1):
        mc = 'NM'[m]
        # panels: sprite WKP<N|M>, frames A.. = ammo_bg1..19
        spr = 'WKP' + mc
        line = []
        for s, bg in enumerate(bgs):
            lump = 'wkp%s%02d' % (mc.lower(), bg)
            count += card_piece(os.path.join(art, 'ammo_bg%d.png' % bg), PANEL_W, PANEL_H, PANEL_S, (0, 0, 0), m,
                                os.path.join(vdir, lump + '.kvx'))
            frame(spr, letters[s], lump, PANEL_S); line.append(letters[s])
        states.append(('P' + mc, spr, line))
        # labels: WKL<N|M>
        spr = 'WKL' + mc
        line = []
        for k, name in enumerate(LABELS):
            lump = 'wkl%s%d' % (mc.lower(), k)
            count += card_piece(os.path.join(art, name + '.png'), 88, 12, LABEL_S,
                                add(LABEL_AT, (0, FRONT, 0)), m, os.path.join(vdir, lump + '.kvx'))
            frame(spr, letters[k], lump, LABEL_S); line.append(letters[k])
        states.append(('L' + mc, spr, line))
        # digits: big slots WKB<N|M><0..2>, small WKS<N|M><0..2>
        for kind, slots, scale in (('B', BIG_AT, BIG_S), ('S', SMALL_AT, SMALL_S)):
            for si, sat in enumerate(slots):
                spr = 'W%s%s%d' % (kind, mc, si)
                line = []
                for gi, g in enumerate(GLYPHS):
                    lump = 'wk%s%s%d%s' % (kind.lower(), mc.lower(), si, g)
                    count += card_piece(os.path.join(art, 'digit_%s.png' % g), 12, 12, scale,
                                        add(sat, (0, FRONT, 0)), m, os.path.join(vdir, lump + '.kvx'))
                    frame(spr, letters[gi], lump, scale); line.append(letters[gi])
                states.append(('%s%s%d' % (kind, mc, si), spr, line))

    # VOXELDEF block
    vpath = os.path.join(WHEEL, 'VOXELDEF.txt')
    old = open(vpath).read() if os.path.exists(vpath) else ''
    a0, a1 = '// >>> WRCARD (tools/gen_cards.py)', '// <<< WRCARD'
    if a0 in old:
        pre, rest = old.split(a0, 1); post = rest.split(a1, 1)[1]
    else:
        pre, post = old, ''
    with open(vpath, 'w') as f:
        f.write(pre.rstrip('\n') + ('\n\n' if pre.strip() else '') + a0 + '\n' + '\n'.join(vdef) + '\n' + a1 + post.rstrip('\n') + '\n')

    # ZScript: the states, one label per piece, frames in order (the card walks NextState)
    z = ['// GENERATED by tools/gen_cards.py -- do not edit. The on-gun card pieces (Project Wheel).',
         '// On a Weapon class so a layer owned by the off-hand gun accepts them (p_pspr.cpp:544-551).',
         'class wr_CardStates : Weapon',
         '{',
         '\tDefault { +WEAPON.CHEATNOTWEAPON +WEAPON.NOAUTOSWITCHTO Weapon.SelectionOrder 99999; }',
         '\tconst STYLES = %d;   // Ermac ammo_bg %s, in that order' % (len(bgs), ' '.join(map(str, bgs))),
         '\tconst LABELS = %d;' % len(LABELS),
         '\tconst GLYPHS = %d;   // 0-9, then o, g, d' % len(GLYPHS),
         '\tconst SLOTS = %d;' % len(BIG_AT),
         '\tStates', '\t{']
    for label, spr, frames in states:
        z.append('\t%s:' % label)
        for fr in frames: z.append('\t\t%s %s -1 Bright;' % (spr, fr))
        z.append('\t\tStop;')
    z += ['\t}', '',
          '\t// The first state of a piece. kind 0 panel, 1 label, 2 big digit, 3 small digit; slot for digits.',
          '\t// (FindState wants a constant label, hence the table.)',
          '\tstatic State Piece(int kind, bool mirrored, int slot = 0)',
          '\t{',
          '\t\tlet d = GetDefaultByType("wr_CardStates");',
          '\t\tint k = kind * 100 + (mirrored ? 10 : 0) + slot;',
          '\t\tswitch (k)', '\t\t{']
    for label, spr, frames in states:
        kind = {'P': 0, 'L': 1, 'B': 2, 'S': 3}[label[0]]
        mir = 1 if label[1] == 'M' else 0
        slot = int(label[2:]) if len(label) > 2 else 0
        z.append('\t\tcase %d: return d.FindState("%s");' % (kind * 100 + mir * 10 + slot, label))
    z += ['\t\t}', '\t\treturn null;', '\t}', '}', '']
    with open(os.path.join(WHEEL, 'zscript', 'wheel', 'wr_q_card_states.zs'), 'w') as f:
        f.write('\n'.join(z))
    print('voxels %d, frames %d, voxel cells %d' % (len(vdef), len(vdef), count))


if __name__ == '__main__':
    main()
