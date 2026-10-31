#!/usr/bin/env python3
"""gen_saberhand.py -- Brutal Doom VR's hand round the saber's hilt (owner 2026-10-31: "put the saber in a static pose,
it's just a cylinder"). The hand is the owner's FBX hand (BD22 VR) in one fixed grip pose, moved so its grip hole sits
on the hilt, then baked into the saber's own md3 space for each of the five blade sizes (the hilt is the md3's middle
and does not move; the HAND is fitted to it), so one MODELDEF block draws hilt and hand together on the hand's layer.

    python3 tools/gen_saberhand.py --bd <BD22_VR-Reloaded_2_0_3h.pk3> [--pose fbx_oh_free_R.md3:1] [--tilt 30]

MEASURED (printed): the grip hole of the pose (the empty cells walled by fingers and palm, sliced at four heights), and
the hilt's axis and middle in the saber's frame 0 (surfaces 0-4). The card frame used here is the one the series uses
(X sideways, Y depth + toward the player, Z up): a block with Scale (sx, sy, sz) and Offset (ox, oy, oz) draws md3
point (x, y, z) at X = ox - sy*y, Y = oy + sx*x, Z = oz + sz*z (rig-measured on the cards' wrist).

Writes models/ubqs/rsabhand_s<N>.md3, models/ubqs/rsabhand.png and the hand lines in MODELDEF (between the
"// >>> hand" marks of each held-saber block, replaced on every run)."""
import argparse, math, os, re, sys, zipfile
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, '..', 'TacticalRig', 'tools'))
from gen_handprops import read_md3, write_md3, enc_n, dec_n

HAND_S = (-1.0, 1.0, 1.0); HAND_O = (0.0, -24.0, -10.0)       # BD22 VR's own hand block
SABER_O = (0.0, -29.0, -8.0)
SIZES = [1.126, 1.367, 1.608, 1.849, 2.090]


def to_card(v, S, O): return np.array([O[0] - S[1] * v[1], O[1] + S[0] * v[0], O[2] + S[2] * v[2]])
def from_card(c, S, O): return np.array([(c[1] - O[1]) / S[0], -(c[0] - O[0]) / S[1], (c[2] - O[2]) / S[2]])


def grip_hole(verts):
    """The hole's middle at four heights (md3 z), by 0.5 cm cells: empty, with hand within 3 cm in all four ways."""
    cell = 0.5; pts = []
    for zc in (-3, -1, 1, 3):
        occ = set()
        for p in verts:
            if zc - 1 <= p[2] <= zc + 1 and p[0] > 0: occ.add((math.floor(p[0] / cell), math.floor(p[1] / cell)))
        H = []
        for x in range(0, int(14 / cell)):
            for y in range(int(-6 / cell), int(9 / cell)):
                if (x, y) in occ: continue
                if all(any((x + dx * k, y + dy * k) in occ for k in range(1, 7)) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    H.append(((x + .5) * cell, (y + .5) * cell))
        if H: pts.append((np.mean([h[0] for h in H]), np.mean([h[1] for h in H]), zc, len(H)))
    return pts


def rot_x(deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return np.array([[1, 0, 0], [0, c, -s], [0, s, c]])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--bd', required=True)
    ap.add_argument('--pose', default='fbx_oh_free_R.md3:1')
    ap.add_argument('--tilt', type=float, default=None, help='degrees the hand is turned forward about its grip (default: to the hilt)')
    ap.add_argument('--shift', default='0,0,0', help='extra card-frame move of the hand, cm')
    a = ap.parse_args()
    pname, pfr = a.pose.split(':'); pfr = int(pfr)
    z = zipfile.ZipFile(a.bd)
    hand, _ = read_md3(z.read('models/rsq/fbx/' + pname))
    for s in hand:
        f = s['frames'][min(pfr, len(s['frames']) - 1)]
        s['frames'] = [f]
    hv = [p for s in hand for p, _ in s['frames'][0]]
    holes = grip_hole(hv)
    lo = [h for h in holes if h[2] <= 1]
    hc_md3 = np.array([np.mean([h[0] for h in lo]), np.mean([h[1] for h in lo]), 0.0])
    # the hole's lean: its middle's travel with height over the lower slices
    if len(lo) >= 2: lean = math.degrees(math.atan2(lo[-1][0] - lo[0][0], lo[-1][2] - lo[0][2]))
    else: lean = 0.0
    hc = to_card(hc_md3, HAND_S, HAND_O)
    print('pose %s frame %d: grip hole md3 (%.2f %.2f), card (%.2f %.2f %.2f), leaning %.1f deg forward' % (pname, pfr, hc_md3[0], hc_md3[1], *hc, lean))

    sab, _ = read_md3(open(os.path.join(ROOT, 'models', 'ubqs', 'ubqs_saber.md3'), 'rb').read())
    hilt = np.array([p for s in sab[:5] for p, _ in s['frames'][0]])
    # the hilt's axis: its long direction (principal component), pointing to the emitter (+x, +z in the md3)
    c0 = hilt.mean(0); u, sv, vt = np.linalg.svd(hilt - c0); ax = vt[0] * (1 if vt[0][0] + vt[0][2] > 0 else -1)
    hilt_lean = math.degrees(math.atan2(ax[0], ax[2]))   # from md3 +z toward md3 +x (forward)
    print('hilt: middle md3 (%.2f %.2f %.2f), axis md3 (%.2f %.2f %.2f), %.1f deg forward of upright' % (*c0, *ax, hilt_lean))
    tilt = (hilt_lean - lean) if a.tilt is None else a.tilt
    shift = np.array([float(v) for v in a.shift.split(',')])
    print('hand turned %.1f deg forward about its grip, moved %s cm' % (tilt, shift))

    # card-frame fit: turn about the hole (forward is -Y: a forward lean is a turn about +X... sign by the rig look)
    R = rot_x(-tilt)
    target_c = to_card(c0, (-1.0, 1.0, 1.0), (0.0, 0.0, 0.0))  # placeholder, replaced per size below
    out = []
    for si, sc in enumerate(SIZES):
        S = (-sc, sc, sc)
        hilt_c = to_card(c0, S, SABER_O)
        surfs = []
        for s in hand:
            frame = []
            for p, n in s['frames'][0]:
                c = to_card(np.array(p), HAND_S, HAND_O)
                c = R @ (c - hc) + hilt_c + shift
                v = from_card(c, S, SABER_O)
                # the normal: card turn, then back (the mirror of sx<0 on both sides cancels)
                nv = np.array(dec_n(n)); nc = np.array([-nv[1], nv[0] * -1, nv[2]])
                nc = R @ nc; nm = np.array([-nc[1] * -1, -nc[0], nc[2]])
                frame.append((tuple(v), enc_n(tuple(nm / max(1e-9, np.linalg.norm(nm))))))
            s2 = dict(s); s2['frames'] = [frame]; s2['shaders'] = [b'rsabhand.png'.ljust(64, b'\0') for _ in s['shaders']]
            surfs.append(s2)
        path = os.path.join(ROOT, 'models', 'ubqs', 'rsabhand_s%d.md3' % si)
        write_md3(path, surfs, 1)
        out.append(path)
    open(os.path.join(ROOT, 'models', 'ubqs', 'rsabhand.png'), 'wb').write(z.read('models/rsq/fbx/fbx_hand.png'))

    # MODELDEF: the hand in every held-saber block (UBQS_Saber, UBQS_SaberOff), model 1, every frame
    md = open(os.path.join(ROOT, 'MODELDEF')).read()
    md = re.sub(r'\t// >>> hand\n.*?\t// <<< hand\n', '', md, flags=re.S)
    def fix(m):
        blk = m.group(0)
        sm = re.search(r'Scale -(\d+\.\d+)', blk)
        if not sm or 'Offset 0.0 -29.0 -8.0' not in blk: return blk
        si = min(range(len(SIZES)), key=lambda i: abs(SIZES[i] - float(sm.group(1))))
        frames = re.findall(r'FrameIndex (\w{4}) (\w) 0 \d+', blk)
        add = '\t// >>> hand\n\tModel 1 "rsabhand_s%d.md3"\n\tSkin 1 "rsabhand.png"\n' % si
        add += ''.join('\tFrameIndex %s %s 1 0\n' % f for f in frames)
        add += '\t// <<< hand\n'
        return blk[:blk.rindex('}')] + add + '}'
    md = re.sub(r'Model UBQS_Saber(Off)?\n\{.*?\n\}', fix, md, flags=re.S)
    open(os.path.join(ROOT, 'MODELDEF'), 'w').write(md)
    print('wrote', ', '.join(os.path.basename(p) for p in out), '+ MODELDEF hand lines')


if __name__ == '__main__':
    main()
