#!/usr/bin/env python3
"""gen_hilthand.py -- HAND ON THE HILT (owner 2026-11-03 19:25): "the magazine hold FBX pose for reloading, we could use
that to put the flashlight, the saber, and the whip into it. Assume the hand is set to receive a vertical cylinder, and
we treat the flashlight, whip, and saber as vertical cylinders."

Tool only (docs/ is not packed). Run from QuestSaber/:   python3 docs/hilthand/gen_hilthand.py

The hand is the Force hand's mesh already in this pk3 (models/ubqs/ubqs_fbxhand.md3 = BD22 VR Reloaded's
fbx_oh_hold_R.md3 frame 0, its rifle-magazine hold). Everything below is MEASURED from the two meshes, nothing typed in:

  * THE GRIP (the cylinder the fingers wrap): the hand sliced across its finger span (md3 z -4.5..4.5, the four
    fingers' stack); the largest empty circle in the palm-fingers-thumb pocket whose surroundings close at least 75 % of
    the way round (the C of the hand is open between thumb and fingertips). Its axis is md3 z (the owner's "vertical
    cylinder", confirmed in the top view: docs/hilthand/fit.png).
  * THE SEAT: which way the pocket's tightest wall lies (the mean direction to the hand surface within 0.4 of the
    circle) -- the palm. A hilt thinner than the pocket is laid against it ("the palm on it").
  * THE HILT: models/ubqs/ubqs_saber.md3 frame 0, surfaces 0-4 (the hilt only): its long axis (principal component,
    pointing to the emitter), its middle, its length and its radius along the axis.

THE CARD FRAME (the HUD model frame the series uses: X sideways, Y depth + toward the player, Z up, centimetres):
a block with Scale (sx, sy, sz) and Offset (ox, oy, oz) draws md3 point (x, y, z) at (ox - sy*y, oy + sx*x, oz + sz*z).
The hand's block is BD22's own (Scale -1 1 1, Offset 0 -24 -10); the saber's is Scale (-s, s, s), Offset 0 -29 -8, s per
blade size (ubqs.py HUD_SCALE 1.608 x the five sizes).

THE FIT, per blade size (the hilt never moves: the blade's direction is the game's, UBQS_Data.BladeDirOf):
  1. the hand is turned about its grip's middle by the smallest rotation that lays the grip axis on the hilt axis
     (an angle about the card X axis: the hilt leans forward of the hand's vertical);
  2. it is slid onto the hilt by the shortest move (the grip's middle projected onto the hilt's line), kept so the
     whole finger span stays on the hilt's grip;
  3. it is moved off the axis toward the palm by (pocket radius - hilt radius) so the palm rests on the hilt.

Writes models/ubqs/ubqs_hilthand.md3 (one frame per blade size, A-E = sizes 1-5, in the hand block's own space) and
prints the numbers and the clearance check (hand points inside the hilt) per size."""
import math, os, sys
import numpy as np
from scipy.spatial import cKDTree

HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(os.path.dirname(HERE))   # QuestSaber/
HUB = os.path.dirname(ROOT)
sys.path.insert(0, os.path.join(HUB, 'TacticalRig', 'tools'))
from gen_handprops import read_md3, write_md3, enc_n, dec_n

HAND_S = (-1.0, 1.0, 1.0); HAND_O = (0.0, -24.0, -10.0)   # BD22 VR's RSQ_Hands block (and UBQS_ForceHand's)
SABER_O = (0.0, -29.0, -8.0)
SIZES = [1.126, 1.367, 1.608, 1.849, 2.090]               # the HUD blocks' Scale per blade size (MODELDEF)
FINGERS = (-4.5, 4.5)                                     # md3 z of the hand's finger stack (slices: pinky .. index)
HILT_SURF = 5                                             # surfaces 0-4 are the hilt; 5-10 the blades


def to_card(v, S, O): return np.array([O[0] - S[1] * v[1], O[1] + S[0] * v[0], O[2] + S[2] * v[2]])
def from_card(c, S, O): return np.array([(c[1] - O[1]) / S[0], -(c[0] - O[0]) / S[1], (c[2] - O[2]) / S[2]])
def dir_card(v, S): return np.array([-S[1] * v[1], S[0] * v[0], S[2] * v[2]])
def dir_md3(c, S): return np.array([c[1] / S[0], -c[0] / S[1], c[2] / S[2]])


def surface_samples(surfs, frame=0):
    """the mesh's vertices plus points inside every triangle (so a sparse wall still reads as a wall)"""
    out = []
    for s in surfs:
        V = np.array([p for p, _ in s['frames'][frame]]); T = np.array(s['tris'])
        out.append(V)
        for w in ((1, 1, 1), (2, 1, 1), (1, 2, 1), (1, 1, 2), (4, 1, 1), (1, 4, 1), (1, 1, 4)):
            w = np.array(w, float) / sum(w)
            out.append(V[T[:, 0]] * w[0] + V[T[:, 1]] * w[1] + V[T[:, 2]] * w[2])
    return np.vstack(out)


def measure_grip(P):
    """the pocket's circle across the finger span: centre (md3 x, y), radius, seat direction (md3, unit)"""
    m = (P[:, 2] >= FINGERS[0]) & (P[:, 2] <= FINGERS[1])
    Q = P[m][:, :2]
    kd = cKDTree(Q)
    # the pocket lies forward of the palm (md3 +x) on the thumb side (+y): search there, not inside the hollow palm
    gx, gy = np.meshgrid(np.arange(1.5, 10.0, 0.05), np.arange(0.5, 9.0, 0.05))
    G = np.c_[gx.ravel(), gy.ravel()]
    d, _ = kd.query(G)
    for k in np.argsort(-d):
        c, r = G[k], d[k]
        idx = kd.query_ball_point(c, r + 2.5)
        ang = np.arctan2(Q[idx, 1] - c[1], Q[idx, 0] - c[0])
        cover = len(np.unique(((ang + math.pi) / (2 * math.pi) * 36).astype(int) % 36)) / 36.0
        if cover >= 0.75:
            # the pocket's MOUTH: the directions round the circle with no hand near (between thumb and fingertips);
            # the seat is straight away from it, into the palm and the finger roots
            bins = set(((ang + math.pi) / (2 * math.pi) * 36).astype(int) % 36)
            mouth = [k2 for k2 in range(36) if k2 not in bins]
            a_m = [(k2 + 0.5) / 36.0 * 2 * math.pi - math.pi for k2 in mouth]
            mv = np.array([np.mean(np.cos(a_m)), np.mean(np.sin(a_m))]); mv /= np.linalg.norm(mv)
            return c, r, cover, np.array([-mv[0], -mv[1], 0.0])
    raise SystemExit('no grip pocket found')


def measure_hilt(sab):
    H = np.array([p for s in sab[:HILT_SURF] for p, _ in s['frames'][0]])
    c = H.mean(0)
    _, _, vt = np.linalg.svd(H - c)
    a = vt[0] * (1 if vt[0][0] + vt[0][2] > 0 else -1)       # toward the emitter (md3 +x +z)
    t = (H - c) @ a
    r = np.linalg.norm(np.cross(H - c, a), axis=1)
    return c, a, t, r


def rot_about(axis, ang):
    axis = axis / np.linalg.norm(axis); x, y, z = axis; c, s = math.cos(ang), math.sin(ang); C = 1 - c
    return np.array([[c + x * x * C, x * y * C - z * s, x * z * C + y * s],
                     [y * x * C + z * s, c + y * y * C, y * z * C - x * s],
                     [z * x * C - y * s, z * y * C + x * s, c + z * z * C]])


def main():
    hand, _ = read_md3(open(os.path.join(ROOT, 'models', 'ubqs', 'ubqs_fbxhand.md3'), 'rb').read())
    P = surface_samples(hand)
    gc, gr, cover, seat = measure_grip(P)
    grip_md3 = np.array([gc[0], gc[1], 0.5 * (FINGERS[0] + FINGERS[1])])
    print('GRIP (measured, hand md3): centre (%.2f %.2f), radius %.2f, closed %.0f%% round, axis md3 z, seat (away from the pocket mouth) (%.2f %.2f)'
          % (gc[0], gc[1], gr, cover * 100, seat[0], seat[1]))
    G0 = to_card(grip_md3, HAND_S, HAND_O); gax = dir_card(np.array([0, 0, 1.0]), HAND_S); seat_c = dir_card(seat, HAND_S)
    print('     card: centre (%.2f %.2f %.2f), axis (%.2f %.2f %.2f), seat (%.2f %.2f %.2f)' % (*G0, *gax, *seat_c))

    sab, _ = read_md3(open(os.path.join(ROOT, 'models', 'ubqs', 'ubqs_saber.md3'), 'rb').read())
    hc, ha, ht, hr = measure_hilt(sab)
    print('HILT (measured, saber md3 frame 0): middle (%.2f %.2f %.2f), axis (%.3f %.3f %.3f), along -%.2f..+%.2f'
          % (*hc, *ha, -ht.min(), ht.max()))
    # the grip of the hilt: where it is thin (r max <= 1.05); the emitter shroud and the pommel are thicker
    bins = np.arange(math.floor(ht.min()), ht.max() + 1, 0.5)
    prof = [(b, hr[(ht >= b) & (ht < b + 0.5)].max()) for b in bins if ((ht >= b) & (ht < b + 0.5)).any()]
    # the thin stretch round the hilt's middle, contiguous (the grip): pommel and emitter rings are thicker
    k0 = min(range(len(prof)), key=lambda k: abs(prof[k][0] + 0.25))
    a_, b_ = k0, k0
    while a_ > 0 and prof[a_ - 1][1] <= 1.05: a_ -= 1
    while b_ < len(prof) - 1 and prof[b_ + 1][1] <= 1.05: b_ += 1
    g_lo, g_hi = prof[a_][0], prof[b_][0] + 0.5
    print('     its grip (radius <= 1.05): along %.1f..%.1f; pommel %.1f, emitter %.1f' % (g_lo, g_hi, ht.min(), ht.max()))

    A_c = dir_card(ha, (-1.0, 1.0, 1.0)); A_c /= np.linalg.norm(A_c)
    cosang = float(np.clip(gax @ A_c, -1, 1)); ang = math.acos(cosang)
    rax = np.cross(gax, A_c); rax = rax / np.linalg.norm(rax) if np.linalg.norm(rax) > 1e-9 else np.array([1.0, 0, 0])
    R = rot_about(rax, ang)
    print('TURN: %.2f deg about card (%.2f %.2f %.2f) -- the grip axis onto the hilt (%.1f deg above the aim)'
          % (math.degrees(ang), *rax, 90 - math.degrees(ang)))
    seat_r = R @ seat_c

    frames = [[] for _ in hand]
    for si, sc in enumerate(SIZES):
        S = (-sc, sc, sc)
        P0 = to_card(hc, S, SABER_O)                     # the hilt's middle, card
        t = (G0 - P0) @ A_c                             # shortest slide: the grip's middle onto the hilt's line
        half = 0.5 * (FINGERS[1] - FINGERS[0])
        lo, hi = g_lo * sc + half, g_hi * sc - half      # the finger span kept on the hilt's grip
        t_fit = min(max(t, lo), hi) if lo <= hi else 0.5 * (g_lo + g_hi) * sc
        prof_in = [rm for b, rm in prof if (t_fit - half) / sc - 0.5 <= b <= (t_fit + half) / sc]
        r_hilt = max(prof_in) * sc
        gap = max(0.0, gr - r_hilt)
        on_axis = P0 + A_c * t_fit
        target = on_axis - seat_r * gap                 # the grip's middle: the hilt's axis sits toward the palm by the gap
        move = target - G0
        # the clearance check: hand surface points within the hilt's radius at their place along it
        Pc = np.array([to_card(p, HAND_S, HAND_O) for p in P[::4]])
        Pf = (Pc - G0) @ R.T + target
        rel = Pf - P0; tt = rel @ A_c; rr = np.linalg.norm(rel - np.outer(tt, A_c), axis=1)
        tm = tt / sc
        lim = np.interp(tm, [b + 0.25 for b, _ in prof], [rm for _, rm in prof], left=0, right=0) * sc
        inside = int(((rr < lim) & (tm > ht.min()) & (tm < ht.max())).sum())
        print('size %d (Scale %.3f): slide %.2f -> %.2f along the hilt (grip %.2f..%.2f), hilt radius %.2f, pocket %.2f, '
              'gap %.2f laid to the palm; hand moved (%.2f %.2f %.2f) cm; hand points inside the hilt: %d of %d'
              % (si + 1, sc, t, t_fit, lo, hi, r_hilt, gr, gap, *move, inside, len(Pf)))
        for k, s in enumerate(hand):
            fr = []
            for p, n in s['frames'][0]:
                c = R @ (to_card(np.array(p), HAND_S, HAND_O) - G0) + target
                nv = dir_md3(R @ dir_card(np.array(dec_n(n)), HAND_S), HAND_S)
                fr.append((tuple(from_card(c, HAND_S, HAND_O)), enc_n(tuple(nv / max(1e-9, np.linalg.norm(nv))))))
            frames[k].append(fr)
    surfs = []
    for k, s in enumerate(hand):
        s2 = dict(s); s2['frames'] = frames[k]; s2['shaders'] = [b'fbx_hand.png'.ljust(64, b'\0') for _ in s['shaders']]
        surfs.append(s2)
    out = os.path.join(ROOT, 'models', 'ubqs', 'ubqs_hilthand.md3')
    write_md3(out, surfs, len(SIZES))
    print('wrote', os.path.relpath(out, ROOT), '(%d frames)' % len(SIZES))


if __name__ == '__main__':
    main()
