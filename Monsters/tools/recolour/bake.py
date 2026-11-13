#!/usr/bin/env python3
"""Bake recoloured copies of sprite lumps: one PNG per lump per colour, offsets (grAb) kept.

    bake.py FAMILY OUTDIR TRNSLATE ARCHIVE [ARCHIVE ...]

FAMILY: families/<name>.txt ('sprites' lines: the family's sprite names; 'keep' lines: palette ranges it keeps).
Every lump of those names that the load order ends up with is baked. ARCHIVES in load order.
Writes OUTDIR/<colour>/<LUMP>.png for the twelve colours, and OUTDIR/manifest.txt (lump, source archive, size).
These are the STARTING POINT for hand work: each frame is its own file, to be painted over; re-running the bake
overwrites, so hand-painted frames belong in a separate folder that wins (see the README)."""
import sys, os, io, struct, zlib
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lumps, recipes

def png_offsets(data):
    pos = 8
    while pos < len(data):
        ln, typ = struct.unpack('>I4s', data[pos:pos + 8])
        if typ == b'grAb': return struct.unpack('>ii', data[pos + 8:pos + 16])
        if typ == b'IDAT': break
        pos += 12 + ln
    return None

def strip_grab(data):
    """Brutal Doom's grAb chunks often carry a wrong CRC (the engine does not check it, PIL does): read the offsets
    with png_offsets() and hand PIL the image without them."""
    out = [data[:8]]; pos = 8
    while pos < len(data):
        ln, typ = struct.unpack('>I4s', data[pos:pos + 8])
        if typ != b'grAb': out.append(data[pos:pos + 12 + ln])
        pos += 12 + ln
        if typ == b'IEND': break
    return b''.join(out)

def decode(data, pal):
    """-> RGBA uint8 array, (xoff, yoff) or None"""
    if data[:8] == b'\x89PNG\r\n\x1a\n':
        im = Image.open(io.BytesIO(strip_grab(data))).convert('RGBA')
        return np.array(im), png_offsets(data)
    w, h, lo, to = struct.unpack('<hhhh', data[:8])          # Doom patch
    a = np.zeros((h, w, 4), np.uint8)
    cols = struct.unpack('<%dI' % w, data[8:8 + 4 * w])
    for x, c in enumerate(cols):
        p = c; top = -1
        while data[p] != 255:
            t = data[p]; n = data[p + 1]
            top = t if t > top else top + t                    # tall patches (DeePsea)
            for k in range(n):
                i = data[p + 3 + k]; y = top + k
                if 0 <= y < h: a[y, x] = (pal[i * 3], pal[i * 3 + 1], pal[i * 3 + 2], 255)
            p += n + 4
    return a, (lo, to)

def write_png(path, rgba, offs):
    b = io.BytesIO(); Image.fromarray(rgba, 'RGBA').save(b, 'PNG', optimize=True); d = b.getvalue()
    if offs is not None:
        body = b'grAb' + struct.pack('>ii', *offs)
        chunk = struct.pack('>I', 8) + body + struct.pack('>I', zlib.crc32(body) & 0xffffffff)
        d = d[:33] + chunk + d[33:]                            # after IHDR (8 + 25 bytes)
    open(path, 'wb').write(d)

def main():
    famfile, outdir, trn = sys.argv[1:4]
    lo = lumps.LoadOrder(sys.argv[4:])
    sprites, keep = set(), set()
    for line in open(famfile):
        w = line.split('#')[0].split()
        if not w: continue
        if w[0] == 'sprites': sprites |= set(x.upper() for x in w[1:])
        if w[0] == 'keep':
            for r in w[1:]:
                a, b = r.split(':'); keep |= set(range(int(a), int(b) + 1))
    pal = lo.palette
    P = np.frombuffer(pal, np.uint8).reshape(256, 3).astype(np.int32)
    rec = recipes.load(trn)
    names = sorted(n for n in lo.index if n[:4] in sprites)
    os.makedirs(outdir, exist_ok=True)
    man = open(os.path.join(outdir, 'manifest.txt'), 'w')
    nearest_cache = {}
    for nm in names:
        w = lo.where(nm)
        if not w: print('MISSING', nm); continue
        rgba, offs = decode(lo.read(nm), pal)
        man.write('%s\t%s\t%s\t%d\n' % (nm, os.path.basename(w[0]), w[1] if isinstance(w[1], str) else 'wad', w[2]))
        rgb = rgba[..., :3].astype(np.int32); h, wd = rgb.shape[:2]
        flat = rgb.reshape(-1, 3)
        keys = (flat[:, 0] << 16) | (flat[:, 1] << 8) | flat[:, 2]
        uk, inv = np.unique(keys, return_inverse=True)
        idx = np.empty(len(uk), np.int32)
        for j, k in enumerate(uk):
            if k not in nearest_cache:
                c = np.array([k >> 16, (k >> 8) & 255, k & 255])
                nearest_cache[k] = int(np.argmin(((P[1:] - c) ** 2).sum(1))) + 1   # index 0 is never matched (engine)
            idx[j] = nearest_cache[k]
        pix_idx = idx[inv]
        inten = (flat[:, 0] * 77 + flat[:, 1] * 143 + flat[:, 2] * 37) / 256.0
        for col in recipes.COLOURS:
            t = recipes.table(rec[col])
            for k in keep: t.pop(k, None)
            out = rgba.copy().reshape(-1, 4)
            for i in np.unique(pix_idx):
                if int(i) not in t: continue
                c1, c2 = t[int(i)]
                m = pix_idx == i
                for ch in range(3):
                    s = min(max(c1[ch], 0.0), 2.0); e = min(max(c2[ch], 0.0), 2.0)
                    out[m, ch] = np.clip(s * 255 + inten[m] * (e - s), 0, 255).astype(np.uint8)
            os.makedirs(os.path.join(outdir, col), exist_ok=True)
            write_png(os.path.join(outdir, col, nm + '.png'), out.reshape(h, wd, 4), offs)
    man.close()
    # the lumps' own brightmaps, for the baked copies (GLDEFS takes the full path of a texture; rig rc_t4: with these
    # the driver's frames are pixel-identical to the engine's own sprite)
    with open(os.path.join(outdir, 'GLDEFS.rsrecolour'), 'w') as g:
        g.write('// GENERATED by Monsters/tools/recolour/bake.py: the source sprites brightmaps on their baked copies\n')
        n = 0
        for nm in names:
            if nm not in lo.brightmaps: continue
            for col in recipes.COLOURS:
                g.write('brightmap texture "rsrecolour/%s/%s.png" { %s }\n' % (col, nm, lo.brightmaps[nm])); n += 1
    print('baked', len(names), 'lumps x', len(recipes.COLOURS), 'colours; brightmaps', n)

if __name__ == '__main__':
    main()
