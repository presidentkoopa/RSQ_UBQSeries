#!/usr/bin/env python3
"""RSQ Wheel: make KVX voxels from glyph cells or small PNGs, one voxel per picture, with VOXELDEF lines.

    python3 wr_make_voxels.py <png files or folders...> [--name Name] [--sprite WVAA] [--depth 2]
                              [--scale 1.0] [--pivot center|bottom] [--tint RRGGBB] [--pal <palette>]
                              [--into <Wheel folder>] [--out folder]

Each opaque pixel becomes a column of --depth voxels front to back; transparent pixels are empty.
A picture with no transparency uses its top-left colour as the background. A folder is every PNG in
it, in name order (so an imported font's graphics/wrimport/<PFX>/ folder gives one voxel per glyph,
and Ermac's digit_0..9.png give ten).

Colours: the picture's own (up to 255; more are boiled down with Pillow's median cut), kept in the
KVX palette (6 bits a channel, as KVX stores it). --tint RRGGBB multiplies by a colour (a white
glyph becomes that colour, grey shading becomes darker shades of it). --pal <file> snaps every
colour to the nearest in a palette (any form wr_import_palette.py reads, e.g. the IWAD's PLAYPAL).

Names: voxels are bound to sprite frames, 26 to a sprite name (frames A..Z): --sprite WVAA gives
WVAAA, WVAAB, ... then WVABA ... Writes voxels/<frame>.kvx, a VOXELDEF block
'<frame> = "<frame>" { Scale = .. }', and a ZScript class wr_vox_<Name> whose Spawn state names
every frame (VOXELDEF only binds a voxel to a sprite some actor uses; the class makes the sprites
exist, and cycles through the voxels one a second when spawned). A frame list says which picture
is which frame.

Axes (as the engine draws a KVX through VOXELDEF, AngleOffset left at its default): the picture
faces the way the actor faces, its top up, read left to right from in front.
"""
import argparse, os, re, struct, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from wr_common import clean_name, upsert_block, read_palette, read_blocks
from PIL import Image


def write_kvx(path, vox, size, pivot, pal):
    """vox[(x, y, z)] = palette index. KVX: x and y across, z DOWN; one mip level; 768-byte
    palette at the end, 6 bits a channel. Checked against R_LoadKVX (src/common/models/voxels.cpp):
    xoffset[0] = (xsiz+1)*4 + xsiz*(ysiz+1)*2, the last xoffset ends exactly at the slab data's end,
    xyoffsets are 16-bit and relative to the column's start, slabs are ztop, zleng, cull, colours."""
    xs, ys, zs = size
    if xs * (ys + 1) * 2 > 32767 or zs > 255: raise ValueError('picture too big for a KVX')
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
    mip = struct.pack('<6i', xs, ys, zs, int(pivot[0] * 256), int(pivot[1] * 256), int(pivot[2] * 256))
    mip += struct.pack('<%di' % (xs + 1), *xoff)
    for offs in xyoff: mip += struct.pack('<%dh' % (ys + 1), *offs)
    mip += body
    p = bytearray(768)
    for i, c in enumerate(pal[:256]):
        p[3 * i:3 * i + 3] = bytes(v >> 2 for v in c)
    open(path, 'wb').write(struct.pack('<i', len(mip)) + mip + bytes(p))


def opaque(im):
    im = im.convert('RGBA')
    if im.getextrema()[3][0] == 255:
        bg = im.getpixel((0, 0)); px = im.load()
        for y in range(im.size[1]):
            for x in range(im.size[0]):
                if px[x, y][:3] == bg[:3]: px[x, y] = (0, 0, 0, 0)
    return im


def voxelize(im, depth, pivot_mode, tint, snap):
    """(vox, size, pivot, palette)"""
    im = opaque(im)
    bb = im.getbbox()
    if not bb: return None
    w, h = im.size
    px = im.load()
    cols = []
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 128: continue
            if tint:
                l = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
                r, g, b = (int(t * l) for t in tint)
            if snap:
                r, g, b = min(snap, key=lambda c: (c[0] - r) ** 2 + (c[1] - g) ** 2 + (c[2] - b) ** 2)
            cols.append(((x, y), (r, g, b)))
    uniq = sorted(set(c for _, c in cols))
    if len(uniq) > 255:
        q = Image.new('RGB', (len(cols), 1))
        q.putdata([c for _, c in cols])
        q = q.quantize(255, method=Image.Quantize.MEDIANCUT)
        qp = q.getpalette()
        cols = [(p, tuple(qp[3 * i:3 * i + 3])) for (p, _), i in zip(cols, q.getdata())]
        uniq = sorted(set(c for _, c in cols))
    index = {c: i for i, c in enumerate(uniq)}
    # picture column u -> KVX x, depth -> KVX y, picture row v -> KVX z (KVX z runs down, like
    # the picture). Measured on the rig: with VOXELDEF's default AngleOffset (90) the KVX y axis is
    # the actor's facing, so this x-z face looks the way the actor looks.
    vox = {}
    for (u, v), c in cols:
        for dy in range(depth):
            vox[(u, dy, v)] = index[c]
    size = (w, depth, h)
    pz = h if pivot_mode == 'bottom' else h / 2.0
    pivot = (w / 2.0, depth / 2.0, pz)
    return vox, size, pivot, uniq


def frames(sprite, n):
    s = list(sprite.upper())
    out = []
    for k in range(n):
        if k and k % 26 == 0:
            # next sprite name: count up the last letter (WVAA -> WVAB)
            i = 3
            while True:
                s[i] = chr(ord(s[i]) + 1) if s[i] != 'Z' else 'A'
                if s[i] != 'A' or i == 2: break
                i -= 1
        out.append(''.join(s) + chr(65 + k % 26))
    return out


def gather(inputs):
    files = []
    for p in inputs:
        if os.path.isdir(p):
            files += [os.path.join(p, f) for f in sorted(os.listdir(p)) if f.lower().endswith('.png')]
        else:
            files.append(p)
    return files


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('inputs', nargs='+')
    ap.add_argument('--name')
    ap.add_argument('--sprite', help='4-letter sprite name to start from (default W + 3 letters of the name)')
    ap.add_argument('--depth', type=int, default=2)
    ap.add_argument('--scale', type=float, default=1.0, help='VOXELDEF Scale')
    ap.add_argument('--pivot', choices=['center', 'bottom'], default='center')
    ap.add_argument('--tint')
    ap.add_argument('--pal')
    ap.add_argument('--into'); ap.add_argument('--out')
    a = ap.parse_args(argv)

    name = a.name or clean_name(a.inputs[0].rstrip('/'))
    letters = [c for c in name.upper() if c.isalpha()] + ['X'] * 3
    sprite = (a.sprite or ('W' + ''.join(letters[:3])))[:4].upper()
    if not re.fullmatch(r'[A-Z][A-Z0-9]{3}', sprite): sys.exit('--sprite: four letters or digits, e.g. WVAA')
    tint = tuple(int(a.tint.lstrip('#')[k:k + 2], 16) for k in (0, 2, 4)) if a.tint else None
    snap = [c[:3] for c in read_palette(a.pal)] if a.pal else None
    root = a.into or a.out or ('%s_voxels' % name)
    vdir = os.path.join(root, 'voxels'); os.makedirs(vdir, exist_ok=True)

    # a second import of the same set: its old voxels go first (the set may have shrunk)
    old = read_blocks(os.path.join(root, 'VOXELDEF.txt'), 'voxels').get(name, '')
    for fm in re.findall(r'^([A-Z0-9]{5})\s*=', old, re.M):
        p = os.path.join(vdir, fm + '.kvx')
        if os.path.exists(p): os.remove(p)
    files = gather(a.inputs)
    made = []
    for f in files:
        r = voxelize(Image.open(f), a.depth, a.pivot, tint, snap)
        if r: made.append((f, r))
        else: print('  %s: nothing opaque, skipped' % os.path.basename(f))
    fr = frames(sprite, len(made))
    V = ['// voxels %s from %d pictures by wr_make_voxels.py (depth %d)' % (name, len(made), a.depth)]
    for (f, (vox, size, pivot, pal)), frame in zip(made, fr):
        write_kvx(os.path.join(vdir, frame + '.kvx'), vox, size, pivot, pal)
        V.append('%s = "%s" { Scale = %.3f }   // %s, %dx%d, %d colours' % (
            frame, frame, a.scale, os.path.basename(f), size[0], size[2], len(pal)))
    upsert_block(os.path.join(root, 'VOXELDEF.txt'), 'voxels', name, '\n'.join(V))
    # the class that makes the sprites exist; frames by sprite name, 26 a name
    by_spr = {}
    for frame in fr: by_spr.setdefault(frame[:4], []).append(frame[4])
    Z = ['// generated by wr_make_voxels.py: voxels %s. Spawned, it shows each voxel for a second in turn.' % name,
         '// ' + ', '.join('%s=%s' % (fm, os.path.basename(f)) for (f, _), fm in zip(made, fr)),
         'class wr_vox_%s : Actor' % re.sub(r'[^A-Za-z0-9_]', '_', name),
         '{',
         '\tDefault { +NOGRAVITY; +NOBLOCKMAP; +NOINTERACTION; Radius 4; Height 8; }',
         '\tStates',
         '\t{',
         '\tSpawn:']
    for spr, fl in by_spr.items():
        Z.append('\t\t%s %s 35;' % (spr, ''.join(fl)))
    Z += ['\t\tLoop;', '\t}', '}']
    zdir = os.path.join(root, 'zscript', 'wrimport'); os.makedirs(zdir, exist_ok=True)
    zfile = 'wr_vox_%s.zs' % name
    open(os.path.join(zdir, zfile), 'w').write('\n'.join(Z) + '\n')
    zt = os.path.join(root, 'zscript.txt')
    if a.into and os.path.exists(zt):
        upsert_block(zt, 'voxelclass', name, '#include "zscript/wrimport/%s"' % zfile)
    print('voxels %s: %d KVX (%s..%s), VOXELDEF block, class wr_vox_%s, into %s' % (
        name, len(made), fr[0] if fr else '-', fr[-1] if fr else '-', name, root))
    return name


if __name__ == '__main__':
    main()
