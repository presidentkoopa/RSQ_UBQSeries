#!/usr/bin/env python3
"""gen_whiphand.py -- HAND ON THE HANDLE (owner 2026-11-03 19:25): "the magazine hold FBX pose for reloading, we could use
that to put the flashlight, the saber, and the whip into it. Assume the hand is set to receive a vertical cylinder ... I
know the whip handle and saber are vertical."

Tool only (tools/ is not packed). Run from Whip/:   python3 tools/gen_whiphand.py

The hand: BD22 VR Reloaded's FBX hand in its rifle-magazine hold (fbx_oh_hold_R.md3 frame 0), the very mesh RSQ Saber's
Force hand and Hand on the Hilt draw (read from ../QuestSaber/models/ubqs/ubqs_fbxhand.md3). The fit is RSQ Saber's
(../QuestSaber/docs/hilthand/gen_hilthand.py), measured, not typed:
  * the grip: the pocket the fingers wrap (centre, radius, axis = the hand's md3 z), and the seat (into the palm);
  * the line it is turned onto: RSQ Saber's hilt axis, measured from ubqs_saber.md3 -- so the whip's handle sits in
    the hand exactly as the saber's hilt does (50.3 deg above the aim, the hand turned 39.7 deg about its grip).
The hand is only turned about its grip's middle (it stays where BD22 draws it); the handle runs through the grip,
laid against the palm (its axis toward the palm by pocket radius - handle radius), its butt BUTT_OUT cm below the
pinky edge of the fingers, HANDLEN map units long (whip.zs HANDLEN 8 = 23.5 cm), a 12-sided tube in the handle's skin.

The whip's simulated handle (whip.zs Handle(), the weapon whip with Hand on the Handle on) starts at the same butt and runs
along the same line, so the thong leaves the drawn handle's tip. The numbers it needs are written to
zscript/rsqwp/handfit.zs: the butt from the controller in the hand's frame (cm: in toward the body's middle, forward along
the aim, up) and the angle above the aim. The controller in the card frame is (0, -30, -5): the engine's HUD chain puts a
model 30 cm back and 5 cm up (models.cpp:230; RSQ Saber's UBQS_Data.WorldNudge).

Writes models/rsqwp/rsqwp_hand.md3 (the turned hand), models/rsqwp/rsqwp_handle.md3 (the handle), models/rsqwp/fbx_hand.png
(BD22's skin, the name its Hand Skin Tone looks for) and zscript/rsqwp/handfit.zs, in the hand block's own space
(Scale -1 1 1, Offset 0 -24 -10)."""
import math, os, shutil, sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE); HUB = os.path.dirname(ROOT)
SAB = os.path.join(HUB, 'QuestSaber')
sys.path.insert(0, os.path.join(SAB, 'docs', 'hilthand'))
from gen_hilthand import (read_md3, write_md3, enc_n, dec_n, to_card, from_card, dir_card, dir_md3, surface_samples,
                          measure_grip, measure_hilt, rot_about, HAND_S, HAND_O, FINGERS)

CTRL = np.array([0.0, -30.0, -5.0])     # the controller in the card frame
HANDLEN_CM = 8.0 / 0.34                 # whip.zs HANDLEN (map units) at vr_vunits_per_meter 34
R_HANDLE = 2.2                          # cm: the drawn handle's radius, a little under the pocket (2.61 measured)
BUTT_OUT = 1.5                          # cm of handle below the pinky edge of the fingers


def main():
    hand, _ = read_md3(open(os.path.join(SAB, 'models', 'ubqs', 'ubqs_fbxhand.md3'), 'rb').read())
    P = surface_samples(hand)
    gc, gr, cover, seat = measure_grip(P)
    grip_md3 = np.array([gc[0], gc[1], 0.5 * (FINGERS[0] + FINGERS[1])])
    G0 = to_card(grip_md3, HAND_S, HAND_O); gax = dir_card(np.array([0, 0, 1.0]), HAND_S); seat_c = dir_card(seat, HAND_S)
    sab, _ = read_md3(open(os.path.join(SAB, 'models', 'ubqs', 'ubqs_saber.md3'), 'rb').read())
    _, ha, _, _ = measure_hilt(sab)
    A = dir_card(ha, (-1.0, 1.0, 1.0)); A /= np.linalg.norm(A)
    ang = math.acos(float(np.clip(gax @ A, -1, 1)))
    rax = np.cross(gax, A); rax /= np.linalg.norm(rax)
    R = rot_about(rax, ang)
    up_deg = math.degrees(math.atan2(A[2], -A[1]))
    print('GRIP (measured): centre md3 (%.2f %.2f), radius %.2f, %.0f%% closed; card centre (%.2f %.2f %.2f)' % (gc[0], gc[1], gr, cover * 100, *G0))
    print('TURN: %.2f deg about card (%.2f %.2f %.2f): the grip onto RSQ Saber\'s hilt line, %.2f deg above the aim' % (math.degrees(ang), *rax, up_deg))
    gap = max(0.0, gr - R_HANDLE)
    axis_pt = G0 + (R @ seat_c) * gap                   # the handle's axis through the grip, laid toward the palm
    half = 0.5 * (FINGERS[1] - FINGERS[0])
    butt = axis_pt - A * (half + BUTT_OUT)
    tip = butt + A * HANDLEN_CM
    d = butt - CTRL
    print('handle: radius %.2f, laid %.2f cm to the palm; butt card (%.2f %.2f %.2f), tip (%.2f %.2f %.2f)' % (R_HANDLE, gap, *butt, *tip))
    print('butt from the controller (card): X %.2f, forward %.2f, up %.2f cm' % (d[0], -d[1], d[2]))

    # the hand, turned about its grip
    surfs = []
    for s in hand:
        fr = []
        for p, n in s['frames'][0]:
            c = R @ (to_card(np.array(p), HAND_S, HAND_O) - G0) + G0
            nv = dir_md3(R @ dir_card(np.array(dec_n(n)), HAND_S), HAND_S)
            fr.append((tuple(from_card(c, HAND_S, HAND_O)), enc_n(tuple(nv / max(1e-9, np.linalg.norm(nv))))))
        s2 = dict(s); s2['frames'] = [fr]; s2['shaders'] = [b'fbx_hand.png'.ljust(64, b'\0') for _ in s['shaders']]
        surfs.append(s2)
    write_md3(os.path.join(ROOT, 'models', 'rsqwp', 'rsqwp_hand.md3'), surfs, 1)
    shutil.copyfile(os.path.join(SAB, 'models', 'ubqs', 'fbx_hand.png'), os.path.join(ROOT, 'models', 'rsqwp', 'fbx_hand.png'))

    # the handle: a 12-sided tube from the butt along the line, capped; normals and points in md3 space
    side = np.cross(A, [1.0, 0.0, 0.0]); side /= np.linalg.norm(side); other = np.cross(A, side)
    N = 12; verts, uvs, tris = [], [], []
    for end, t in ((0, 0.0), (1, HANDLEN_CM)):
        for k in range(N + 1):
            a = 2 * math.pi * k / N
            nrm = side * math.cos(a) + other * math.sin(a)
            nm = dir_md3(nrm, HAND_S)
            verts.append((tuple(from_card(butt + A * t + nrm * R_HANDLE, HAND_S, HAND_O)), enc_n(tuple(nm / np.linalg.norm(nm)))))
            uvs.append((k / N, end * 4.0))
    for k in range(N):
        a0, b0 = k, N + 1 + k
        tris += [(a0, a0 + 1, b0), (a0 + 1, b0 + 1, b0)]
    for end, t in ((0, 0.0), (1, HANDLEN_CM)):
        ci = len(verts)
        nm = dir_md3(A * (1 if end else -1), HAND_S)
        verts.append((tuple(from_card(butt + A * t, HAND_S, HAND_O)), enc_n(tuple(nm / np.linalg.norm(nm))))); uvs.append((0.5, 0.5))
        base = end * (N + 1)
        for k in range(N):
            tris.append((ci, base + k, base + k + 1) if end == 0 else (ci, base + k + 1, base + k))
    hs = dict(name=b'rsqwp_handle'.ljust(64, b'\0'), shaders=[b'rsqwhiph.png'.ljust(64, b'\0')], tris=tris, uvs=uvs, frames=[verts])
    write_md3(os.path.join(ROOT, 'models', 'rsqwp', 'rsqwp_handle.md3'), [hs], 1)

    zs = os.path.join(ROOT, 'zscript', 'rsqwp', 'handfit.zs')
    open(zs, 'w').write("""// GENERATED by tools/gen_whiphand.py -- do not edit by hand. HAND ON THE HANDLE (owner 2026-11-03): where the drawn
// handle (models/rsqwp/rsqwp_handle.md3, in the FBX hand's magazine-hold grip) starts, from the controller, in the hand's
// own frame (cm: X = card X, forward along the aim, up), and its angle above the aim. whip.zs Handle() hangs the
// simulated handle on the same line, so the thong leaves the drawn handle's tip.
struct RSQWP_HandFit
{
	const GRIP_UP  = %.3f;   // degrees above the aim (RSQ Saber's hilt line, measured)
	const BUTT_X   = %.3f;   // cm, card X
	const BUTT_FWD = %.3f;   // cm along the aim
	const BUTT_UP  = %.3f;   // cm, the hand's up
}
""" % (up_deg, d[0], -d[1], d[2]))
    print('wrote models/rsqwp/rsqwp_hand.md3, rsqwp_handle.md3, fbx_hand.png, zscript/rsqwp/handfit.zs')


if __name__ == '__main__':
    main()
