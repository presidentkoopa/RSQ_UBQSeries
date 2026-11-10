#!/usr/bin/env python3
"""flip_export.py -- the ROCKET BLAST and the MEGA BLAST (MEGA2, the chain finale) as flipbooks. (Tool only;
Grenade/tools/ never ships.)

    python3 Grenade/tools/flip_export.py          writes sprites/rsqgn/flip/ and zscript/rsqgn/flip_data.zs

THE SPECIFICATION IS THE PYTHON: the approved mockups, run as they are (copies kept in tools/flip_spec/; they read
their source art from /tmp/eosfr, /tmp/fx_agentB/cut and the repo):
  ROCKET  /tmp/fx_rocket/rocket.py (owner: "i love all of them but the explosion fire running back down the rocket trail
          is confusing to me" -> REACH=0, no flashback): shot_floor and shot_air, each from its impact tic. The rocket,
          its trail, the cacodemon and its gore, the floor scorch and the floor glow are the mockup's scene, not the
          blast: they are left out. The WALL shot is not exported: its fire folds onto a wall seen side-on, which no
          billboard can hold at every angle; a rocket into a wall plays the AIR blast.
  MUSH    /tmp/fx_mega/mega.py, the mushroom mega (owner 11-10: "the mushroom cloud one every 5, but make it big"),
          the same way.
  MEGA    /tmp/fx_mega2/mega2.py (owner: "of the two of these i like the second one, non mushroom, more"): its whole
          render from the blast tic, without the barrel (the game's barrel is already there), the room or its floor
          glow.

HOW: each tic is drawn twice, over black and over white; the two give each pixel's own colour and opacity (additive
fire comes out opaque, in its own colour). Each tic becomes one sprite frame, trimmed to its pixels, with a grAb
offset that puts the mockup's blast point on the actor (the floor line for floor blasts). In the game one billboard
plays them a frame a tic (explosions.zs RSQGN_Flip) at the mockup's scale, with one light following the mockup's
glow. It is the mockup exactly, flat: a billboard, not separate pieces.
"""
import os, sys, struct, importlib, random
import numpy as np
from PIL import Image, PngImagePlugin

HERE = os.path.dirname(os.path.abspath(__file__))
GREN = os.path.dirname(HERE)
OUT = os.path.join(GREN, 'sprites', 'rsqgn', 'flip')
DATA = os.path.join(GREN, 'zscript', 'rsqgn', 'flip_data.zs')
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'


def save_png(path, rgba, gx, gy):
    info = PngImagePlugin.PngInfo()
    info.add(b'grAb', struct.pack('>ii', int(gx), int(gy)))
    Image.fromarray(rgba, 'RGBA').save(path, pnginfo=info, optimize=True)


def matte(black, white):
    """two renders of one tic -> RGBA: opacity from how much the background shows through, colour un-premultiplied"""
    b = black.astype(np.float32); w = white.astype(np.float32)
    a = 1.0 - (w - b).mean(axis=2) / 255.0
    a = np.clip(a, 0, 1)
    a[a < 0.06] = 0
    rgb = np.where(a[..., None] > 0, b / np.maximum(a[..., None], 1e-3), 0)
    return np.dstack([np.clip(rgb, 0, 255), a * 255]).astype(np.uint8)


# ---------------------------------------------------------------------------------------------------------------- ROCKET
def rocket_shots():
    sys.path.insert(0, '/tmp/fx_rocket/lib'); sys.path.insert(0, '/tmp/fx_rocket'); os.chdir('/tmp/fx_rocket')
    R = importlib.import_module('rocket')
    import fxg, seqg
    U, BX, FLOOR = fxg.U, fxg.BX, fxg.FLOOR
    L = fxg.L

    def items_floor():
        rng = random.Random(2)
        d = R.unit(1.0, .30); hit = (BX + 6, FLOOR - 3)
        bx, by = BX, FLOOR - 14
        rk = R.Rocket(hit, d)
        it = [R.Core(bx, by, clip=True), R.Boil(bx, by - 6, jet=(0, -1), start=1, n=20, R=42, seed=6, clip=True, rise=(0, -.55), jo=.75),
              R.Backblast(hit, d, clip=True)]
        it += seqg.pops(rng, bx, FLOOR - 4 * U, size=70)
        it.append(seqg.PixRing(bx, FLOOR + 2, 128, 1, 7, squash=.12, floor_cut=False, r0=24))
        for k, (dd, tt) in enumerate([(60, 2), (-60, 2), (110, 4), (-110, 4), (150, 6), (-150, 6)]):
            it.append(L(fxg.pick('ruf_dust', [1, 2, 2]), [2, 3, 4], start=tt, pos=(bx + dd * U, FLOOR - 5), size=24 + abs(dd) * .05,
                        grow=.6, ramp=fxg.R_DUST, add=False, alpha=.85, fade=.5, clip=True, nokind=True, flip=k % 2 == 1))
        it.append(R.Spray(bx, FLOOR - 4, 10, 170, n=24, vmax=40, seed=21))
        it.append(R.Chunks(bx, FLOOR - 6, 25, 155, n=30, speed=(5, 14), seed=22))
        it.append(seqg.Embers(3, bx, FLOOR, seed=23))
        it.append(R.Stub(bx + 4, FLOOR - 10, 4.0, -9.5, start=2))
        return it, (bx, FLOOR), 74

    def items_air():
        rng = random.Random(3)
        ccx, ccy = BX + 70, int(fxg.Z(150))
        d = R.unit(1.0, -.22); hit = (ccx - 34, ccy + 4)
        bx, by = hit
        it = [R.Core(bx, by), R.Boil(bx + 6, by, jet=(0, -1), start=1, n=20, R=42, seed=7, rise=(0, -.5), jo=.45), R.Backblast(hit, d)]
        it += seqg.pops(rng, bx, by, size=64)
        it.append(seqg.PixRing(bx, by, 128, 1, 7, r0=22))
        it.append(R.Spray(bx, by, 0, 360, n=26, vmax=40, seed=31))
        it.append(R.Chunks(bx, by, 0, 360, n=10, speed=(4, 11), seed=33))       # the hot casing bits (the caco's gore left out)
        it.append(seqg.Embers(3, bx, by, seed=35))
        it.append(R.Stub(bx, by - 4, -3.0, -6.0, start=2))
        return it, (bx, by), 76

    def render(items, end, bgval):
        frames = []
        for t in range(0, end):
            c = np.zeros((fxg.CH, fxg.CW, 3)); c[:] = bgval
            for i in sorted(items, key=lambda i: getattr(i, 'z', 0)):
                if hasattr(i, 'ops'):
                    for o in i.ops(t): fxg.blit(c, *o)
                if hasattr(i, 'draw'): i.draw(c, t)
                elif not hasattr(i, 'ops'):
                    r = i.render(t)
                    if r: fxg.blit(c, *r, i.add)
            frames.append(np.clip(c, 0, 255).astype(np.uint8))
        return frames

    out = {}
    for name, mk, floor in (('floor', items_floor, True), ('air', items_air, False)):
        it, ref, end = mk(); blk = render(it, end, 0)
        it, ref, end = mk(); wht = render(it, end, 255)
        out[name] = ([matte(b, w) for b, w in zip(blk, wht)], ref, 1.0 / U, floor)
    # the glow (rocket.py: banded_glow(env(1.0, 1, 12)) on the floor; env(.55, 1, 9) in the air): its strength a tic
    out['floor'] += ([fxg.env(1.0, 1, 12)(t) for t in range(74)], (255, 150, 60), 330 / 2.0)
    out['air'] += ([fxg.env(.55, 1, 9)(t) for t in range(76)], (255, 150, 60), 330 / 2.0)
    sys.path.remove('/tmp/fx_rocket/lib'); sys.path.remove('/tmp/fx_rocket')
    for m in ('fxg', 'seqg', 'rocket', 'lmp'): sys.modules.pop(m, None)
    return out


# ---------------------------------------------------------------------------------------------------------------- MEGA
def mega_shot(d='/tmp/fx_mega2', mod='mega2', key='mega', keep_whole=('core', 'swell')):
    """MEGA2 (/tmp/fx_mega2 mega2.py) or the mushroom MEGA (/tmp/fx_mega mega.py): their render() without the room"""
    sys.path.insert(0, d + '/lib'); sys.path.insert(0, d); os.chdir(d)
    for m in ('fx', 'debris_v3', mod): sys.modules.pop(m, None)
    M = importlib.import_module(mod)

    def render(bgval):
        L, LB, FL, S, B, BF, D, light, lcol = M.build()
        P = M.build_cloud(random.Random(7)); V = M.build_veins(random.Random(11))
        frames = []
        for t in range(M.T0, M.END):
            c = np.zeros((M.CH, M.CW, 3), np.float32); c[:] = bgval
            for b in B: b.draw(c, t)
            for l in LB:
                rr = l.at(t)
                if rr: M.blit(c, *rr, l.add, l.gain, clip_floor=True)
            M.draw_cloud(c, P, V, t)
            for l in L:
                if l.name == 'barrel': continue
                rr = l.at(t)
                if rr: M.blit(c, *rr, l.add, l.gain, clip_floor=not l.name.startswith(keep_whole))
            for s in S: s.draw(c, t)
            for b in BF: b.draw(c, t)
            for dd in D: dd.draw(c, t)
            for l in FL:
                rr = l.at(t)
                if rr: M.blit(c, *rr, l.add, l.gain)
            frames.append((np.clip(c, 0, 1) * 255).astype(np.uint8))
        return frames, light

    blk, light = render(0.0)
    wht, _ = render(1.0)
    fr = [matte(b, w) for b, w in zip(blk, wht)]
    glow = [min(1.0, light(t)) for t in range(M.T0, M.END)]
    sys.path.remove(d + '/lib'); sys.path.remove(d)
    for m in ('fx', 'debris_v3', mod): sys.modules.pop(m, None)
    return {key: (fr, (M.BX, M.FY), 1.0 / M.PX, True, glow, (255, 158, 66), 210.0)}


# ---------------------------------------------------------------------------------------------------------------- WRITE
SEQ = [('floor', 'QRF', 'ROCKET_FLOOR'), ('air', 'QRA', 'ROCKET_AIR'), ('mega', 'QMG', 'MEGA'), ('mush', 'QMU', 'MUSH')]


def main():
    shots = rocket_shots()
    shots.update(mega_shot())
    shots.update(mega_shot('/tmp/fx_mega', 'mega', 'mush', ('core', 'dome')))
    if os.path.isdir(OUT):
        for f in os.listdir(OUT): os.remove(os.path.join(OUT, f))
    os.makedirs(OUT, exist_ok=True)
    zs = ['// GENERATED by Grenade/tools/flip_export.py from the approved mockups (/tmp/fx_rocket rocket.py, /tmp/fx_mega2',
          '// mega2.py); do not edit. The flipbooks RSQGN_Flip plays (explosions.zs): a sprite name per 26 frames, a frame a tic.',
          'class RSQGN_FlipData', '{']
    names_all = []
    for i, (key, pre, const) in enumerate(SEQ):
        fr, (rx, ry), scale, floor, glow, gcol, grad = shots[key]
        names = []
        for t, a in enumerate(fr):
            nm = '%s%d' % (pre, t // 26); L = LETTERS[t % 26]
            if nm not in names: names.append(nm)
            al = a[..., 3]
            ys, xs = np.nonzero(al > 0)
            if len(xs) == 0:
                a = np.zeros((1, 1, 4), np.uint8); x0 = y0 = 0; gx, gy = 0, 0
            else:
                x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
                a = a[y0:y1, x0:x1]
                gx, gy = int(round(rx - x0)), int(round(ry - y0))
            save_png(os.path.join(OUT, '%s%s0.png' % (nm, L)), np.ascontiguousarray(a), gx, gy)
        names_all += names
        zs.append('\tconst %s = %d;' % (const, i))
        print('%s: %d frames, %s, %.3f map units a pixel' % (key, len(fr), ' '.join(names), scale))
        SEQD = {'names': names, 'n': len(fr), 'scale': scale, 'floor': floor, 'glow': glow, 'gcol': gcol, 'grad': grad}
        shots[key] = SEQD
    zs.append('\tconst COUNT = %d;' % len(SEQ))
    def arr(fn, typ, vals):
        zs.append('\tstatic clearscope %s %s(int i) { static const %s %s_T[] = { %s }; return %s_T[i]; }' % (typ, fn, typ, fn, ', '.join(vals), fn))
    arr('Frames', 'int', [str(shots[k]['n']) for k, _, _ in SEQ])
    arr('Scale', 'double', ['%.4f' % shots[k]['scale'] for k, _, _ in SEQ])
    arr('OnFloor', 'int', ['1' if shots[k]['floor'] else '0' for k, _, _ in SEQ])
    arr('GlowCol', 'int', ['0x%02X%02X%02X' % shots[k]['gcol'] for k, _, _ in SEQ])
    arr('GlowRad', 'double', ['%.1f' % shots[k]['grad'] for k, _, _ in SEQ])
    # the sprite names a flipbook uses, by sequence: first index and count
    first, cnt, flat = [], [], []
    for k, _, _ in SEQ:
        first.append(str(len(flat))); cnt.append(str(len(shots[k]['names']))); flat += ['"%s"' % n for n in shots[k]['names']]
    arr('NameFirst', 'int', first)
    arr('NameCount', 'int', cnt)
    arr('NameAt', 'String', flat)
    # the glow a tic, all sequences one after another (GlowFirst: where each starts)
    gfirst, gflat = [], []
    for k, _, _ in SEQ:
        gfirst.append(str(len(gflat))); gflat += ['%.3f' % g for g in shots[k]['glow']]
    arr('GlowFirst', 'int', gfirst)
    arr('GlowAt', 'double', gflat)
    zs.append('}')
    # every sprite name has to appear in a state to be loaded: one dummy actor lists them
    zs += ['', '// every flipbook sprite name in a state (sprites only load when a state names them)',
           'class RSQGN_FlipSprites : Actor', '{', '\tStates', '\t{', '\tSpawn:']
    for nm in names_all: zs.append('\t\t%s A -1;' % nm)
    zs += ['\t\tStop;', '\t}', '}', '']
    open(DATA, 'w').write('\n'.join(zs))
    print('wrote', DATA, 'and', len(os.listdir(OUT)), 'frames in', OUT)


if __name__ == '__main__':
    main()
