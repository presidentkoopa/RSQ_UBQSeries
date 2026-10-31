#!/usr/bin/env python3
"""gen_whiphand.py -- the whip's handle held in Brutal Doom VR's hand (owner 2026-10-31: "the whip handle the same"):
one static grip, the handle fixed in the fist, drawn on the hand's layer with the hand. The SAME hand and grip as the
saber's (QuestSaber/tools/gen_saberhand.py: BD's fist, fbx_oh_free_R frame 1, turned forward so its grip hole runs
along the line the saber's hilt does, 40 degrees forward of upright).

The hand stays where Brutal Doom VR draws it (only turned about its own grip hole); the handle runs through the hole,
its butt GRIP_IN cm below the fist, and HANDLEN (8 map units, 23.5 cm) long, where the thong starts. whip.zs hangs its
simulated handle from the same butt (printed: cm from the controller, card (0, -30, -5)) along the controller's aim
turned up GRIP_UP degrees (Handle()), so the simulated handle and this one are one line.

    python3 tools/gen_whiphand.py --bd <BD22_VR-Reloaded_2_0_3h.pk3>

Writes models/rsqwp/whiphand.md3 (the hand), whiphdl.md3 (the handle) and whiphand.png, in the hand block's own md3
space (Scale -1 1 1, Offset 0 -24 -10)."""
import argparse, math, os, sys, zipfile
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, '..', 'TacticalRig', 'tools'))
sys.path.insert(0, os.path.join(ROOT, '..', 'QuestSaber', 'tools'))
from gen_handprops import read_md3, write_md3, enc_n
from gen_saberhand import to_card, from_card, grip_hole, rot_x, HAND_S, HAND_O

CTRL = np.array([0.0, -30.0, -5.0])     # the controller in the card frame (AttackPos)
GRIP_UP = 50.0                          # degrees above the aim (whip.zs Handle())
HANDLEN_CM = 8.0 / 0.34                 # 8 map units
GRIP_IN = 5.0                           # cm from the butt to the middle of the fist
R_HANDLE = 1.4                          # cm, the handle's radius


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--bd', required=True); a = ap.parse_args()
    z = zipfile.ZipFile(a.bd)
    hand, _ = read_md3(z.read('models/rsq/fbx/fbx_oh_free_R.md3'))
    for s in hand: s['frames'] = [s['frames'][min(1, len(s['frames']) - 1)]]
    hv = [p for s in hand for p, _ in s['frames'][0]]
    lo = [h for h in grip_hole(hv) if h[2] <= 1]
    hc = to_card(np.array([np.mean([h[0] for h in lo]), np.mean([h[1] for h in lo]), 0.0]), HAND_S, HAND_O)
    lean = math.degrees(math.atan2(lo[-1][0] - lo[0][0], lo[-1][2] - lo[0][2]))
    axis = np.array([0.0, -math.cos(math.radians(GRIP_UP)), math.sin(math.radians(GRIP_UP))])   # forward -Y, up +Z
    tilt = (90.0 - GRIP_UP) - lean
    R = rot_x(-tilt)
    grip = hc
    butt = hc - axis * GRIP_IN
    d = butt - CTRL
    print('butt: card (%.2f %.2f %.2f), from the controller: %.2f cm in (X), %.2f cm forward (-Y), %.2f cm up (Z)' % (*butt, d[0], -d[1], d[2]))
    print('fist hole card (%.2f %.2f %.2f), leaning %.1f; turned %.1f forward; grip at (%.2f %.2f %.2f)' % (*hc, lean, tilt, *grip))
    surfs = []
    for s in hand:
        frame = []
        for p, n in s['frames'][0]:
            c = R @ (to_card(np.array(p), HAND_S, HAND_O) - hc) + grip
            frame.append((tuple(from_card(c, HAND_S, HAND_O)), n))
        s2 = dict(s); s2['frames'] = [frame]; s2['shaders'] = [b'whiphand.png'.ljust(64, b'\0') for _ in s['shaders']]
        surfs.append(s2)
    write_md3(os.path.join(ROOT, 'models', 'rsqwp', 'whiphand.md3'), surfs, 1)
    open(os.path.join(ROOT, 'models', 'rsqwp', 'whiphand.png'), 'wb').write(z.read('models/rsq/fbx/fbx_hand.png'))

    # the handle: a 12-sided tube from the controller along the axis, capped, the plaited skin round it
    side = np.cross(axis, [1.0, 0.0, 0.0]); side /= np.linalg.norm(side); other = np.cross(axis, side)
    N = 12; verts, uvs, tris = [], [], []
    for end, t in ((0, 0.0), (1, HANDLEN_CM)):
        for k in range(N + 1):
            ang = 2 * math.pi * k / N
            nrm = side * math.cos(ang) + other * math.sin(ang)
            c = butt + axis * t + nrm * R_HANDLE
            nm = np.array([-nrm[1] * -1, -nrm[0], nrm[2]])
            verts.append((tuple(from_card(c, HAND_S, HAND_O)), enc_n(tuple(nm))))
            uvs.append((k / N, end * 4.0))
    for k in range(N):
        a0, b0 = k, N + 1 + k
        tris += [(a0, b0, a0 + 1), (a0 + 1, b0, b0 + 1)]
    for end, t in ((0, 0.0), (1, HANDLEN_CM)):
        ci = len(verts)
        verts.append((tuple(from_card(butt + axis * t, HAND_S, HAND_O)), enc_n((0.0, 0.0, 1.0)))); uvs.append((0.5, 0.5))
        base = end * (N + 1)
        for k in range(N):
            tris.append((ci, base + k + 1, base + k) if end == 0 else (ci, base + k, base + k + 1))
    hs = dict(name=b'whiphandle'.ljust(64, b'\0'), shaders=[b'rsqwhiph.png'.ljust(64, b'\0')], tris=tris, uvs=uvs, frames=[verts])
    write_md3(os.path.join(ROOT, 'models', 'rsqwp', 'whiphdl.md3'), [hs], 1)
    print('handle: %.1f cm along (%.2f %.2f %.2f) from the butt' % (HANDLEN_CM, *axis))


if __name__ == '__main__':
    main()
