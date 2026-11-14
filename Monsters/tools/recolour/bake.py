#!/usr/bin/env python3
"""Bake recoloured copies of sprite lumps: one PNG per lump per colour, offsets (grAb) kept.

    bake.py FAMILY OUTDIR TRNSLATE ARCHIVE [ARCHIVE ...]

FAMILY: families/<name>.txt: its sprite names and its art rules (parts, group rules, masks; see families/imp.txt).
Every lump of those names that the load order ends up with is baked. ARCHIVES in load order.
Writes OUTDIR/<colour>/<LUMP>.png for the twelve colours, and OUTDIR/manifest.txt (lump, source archive, size, how).
Each frame is painted per part with the colour's own palettes (paint.py, ramps.py), not tinted; lumps the family marks
'tint' keep the old flat tint. Frames painted by hand live in HAND/<colour>/<LUMP>.png (default: OUTDIR/../hand, or
$RSRC_HAND); the bake never writes there and copies them over its own output last, so a hand frame always wins."""
import sys, os, io, re, struct, zlib
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lumps, recipes, paint, ramps

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

def nearest_index(rgba, P, cache):
    """-> HxW palette index of each pixel (nearest entry, 0 never matched: the engine's rule)."""
    rgb = rgba[..., :3].astype(np.int32); h, wd = rgb.shape[:2]
    flat = rgb.reshape(-1, 3)
    keys = (flat[:, 0] << 16) | (flat[:, 1] << 8) | flat[:, 2]
    uk, inv = np.unique(keys, return_inverse=True)
    idx = np.empty(len(uk), np.int32)
    for j, k in enumerate(uk):
        if k not in cache:
            c = np.array([k >> 16, (k >> 8) & 255, k & 255])
            cache[k] = int(np.argmin(((P[1:] - c) ** 2).sum(1))) + 1
        idx[j] = cache[k]
    return idx[inv].reshape(h, wd)

def tint_bake(rgba, pix_idx, t):
    """The old flat tint (the approved recipe per palette index), for lumps the family file marks 'tint'."""
    flat = rgba[..., :3].astype(np.int32).reshape(-1, 3); pi = pix_idx.reshape(-1)
    inten = (flat[:, 0] * 77 + flat[:, 1] * 143 + flat[:, 2] * 37) / 256.0
    out = rgba.copy().reshape(-1, 4)
    for i in np.unique(pi):
        if int(i) not in t: continue
        c1, c2 = t[int(i)]; m = pi == i
        for ch in range(3):
            s = min(max(c1[ch], 0.0), 2.0); e = min(max(c2[ch], 0.0), 2.0)
            out[m, ch] = np.clip(s * 255 + inten[m] * (e - s), 0, 255).astype(np.uint8)
    return out.reshape(rgba.shape)

_JOB = None

def _paint_one(nm):
    """all twelve colours of one lump (pass 2; run in worker processes when RSRC_JOBS > 1: the same files either way)"""
    src, fam, rec, keep, sts, outdir = _JOB
    rgba, offs, idx, part, w = src[nm]
    for col in recipes.COLOURS:
        if fam.is_tint(nm):
            t = recipes.table(rec[col])
            for k in keep: t.pop(k, None)
            out = tint_bake(rgba, idx, t)
        else:
            out = paint.paint(rgba, part, ramps.LOOKS[col], sts[fam.statgroup(nm)])
        write_png(os.path.join(outdir, col, nm + '.png'), out, offs)

def main():
    famfile, outdir, trn = sys.argv[1:4]
    lo = lumps.LoadOrder(sys.argv[4:])
    fam = paint.Family(famfile)
    keep = set(i for i, p in fam.part_of.items() if p == paint.KEEP)
    pal = lo.palette
    P = np.frombuffer(pal, np.uint8).reshape(256, 3).astype(np.int32)
    rec = recipes.load(trn)
    names = sorted(n for n in lo.index if n[:4] in fam.sprites and not fam.is_skip(n))
    os.makedirs(outdir, exist_ok=True)
    cache = {}
    # pass 1: decode, find the parts, gather the family's shading statistics per part (per statgroup, if the family
    # file has any: a family whose looks differ, a blue uniform and a tan one, gets each look's own)
    src = {}
    sts = {}
    for nm in names:
        w = lo.where(nm)
        if not w: print('MISSING', nm); continue
        rgba, offs = decode(lo.read(nm), pal)
        idx = nearest_index(rgba, P, cache)
        part = fam.classify(nm, idx, rgba[..., 3] > 0, rgba)
        src[nm] = (rgba, offs, idx, part, w)
        if not fam.is_tint(nm): sts.setdefault(fam.statgroup(nm), paint.Stats()).add(paint.to_oklab(rgba[..., :3]), part)
    for st in sts.values(): st.finish()
    # pass 2: paint every colour. OUTDIR is shared by every family: manifest.txt and GLDEFS.rsrecolour keep the lines of
    # the lumps this bake does not make (another family's), and are written in lump order.
    mpath = os.path.join(outdir, 'manifest.txt')
    lines = {}
    if os.path.exists(mpath):
        for l in open(mpath):
            if l.strip() and l.split('\t')[0] not in src: lines[l.split('\t')[0]] = l
    for nm, (rgba, offs, idx, part, w) in src.items():
        lines[nm] = '%s\t%s\t%s\t%d\t%s\n' % (nm, os.path.basename(w[0]), w[1] if isinstance(w[1], str) else 'wad', w[2],
                                              'tint' if fam.is_tint(nm) else 'paint')
    with open(mpath, 'w') as man:
        for k in sorted(lines): man.write(lines[k])
    for col in recipes.COLOURS: os.makedirs(os.path.join(outdir, col), exist_ok=True)
    global _JOB
    _JOB = (src, fam, rec, keep, sts, outdir)
    jobs = int(os.environ.get('RSRC_JOBS', '1'))
    if jobs > 1:
        import multiprocessing as mp
        with mp.get_context('fork').Pool(jobs) as pool: pool.map(_paint_one, list(src), chunksize=8)
    else:
        for nm in src: _paint_one(nm)
    # frames painted by hand win: HAND/<colour>/<LUMP>.png is copied over the bake (the bake never writes into HAND)
    hand = os.environ.get('RSRC_HAND') or os.path.join(os.path.dirname(os.path.abspath(outdir)), 'hand')
    nh = 0
    if os.path.isdir(hand):
        import shutil
        for col in recipes.COLOURS:
            d = os.path.join(hand, col)
            if not os.path.isdir(d): continue
            for f in sorted(os.listdir(d)):
                if f.lower().endswith('.png'):
                    shutil.copyfile(os.path.join(d, f), os.path.join(outdir, col, f.upper()[:-4] + '.png')); nh += 1
    # the lumps' own brightmaps, for the baked copies (GLDEFS takes the full path of a texture; rig rc_t4: with these
    # the driver's frames are pixel-identical to the engine's own sprite)
    gpath = os.path.join(outdir, 'GLDEFS.rsrecolour')
    bm = {}                                                    # lump -> its lines, in colour order
    if os.path.exists(gpath):
        for l in open(gpath):
            m = re.match(r'brightmap texture "rsrecolour/[^/]+/([^.]+)\.png"', l)
            if m and m.group(1) not in src: bm.setdefault(m.group(1), []).append(l)
    n = 0
    for nm in names:
        if nm not in lo.brightmaps: continue
        bm[nm] = ['brightmap texture "rsrecolour/%s/%s.png" { %s }\n' % (col, nm, lo.brightmaps[nm]) for col in recipes.COLOURS]
        n += len(recipes.COLOURS)
    with open(gpath, 'w') as g:
        g.write('// GENERATED by Monsters/tools/recolour/bake.py: the source sprites brightmaps on their baked copies\n')
        for k in sorted(bm): g.writelines(bm[k])
    print('baked', len(src), 'lumps x', len(recipes.COLOURS), 'colours (painted %d, tint %d); hand frames %d; brightmaps %d'
          % (sum(1 for k in src if not fam.is_tint(k)), sum(1 for k in src if fam.is_tint(k)), nh, n))

if __name__ == '__main__':
    main()
