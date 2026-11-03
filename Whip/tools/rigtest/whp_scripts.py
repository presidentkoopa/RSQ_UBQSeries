#!/usr/bin/env python3
"""TEST ONLY (never ships). Console scripts for tools/rigtest/whp.sh: one tic per `wait 1` (vid_maxfps 35 gives
the rig exactly one frame a tic -- measured: whp_F frame n = gametic n+1). The rig's controller cvars can only be
set from the console (a play-scope CVar.SetString on an engine cvar aborts), so the hand is driven here.

    python3 tools/rigtest/whp_scripts.py <scenario> [hand]     prints the script
scenarios: snap walk swing coil yank hands idle mark sway jitter wall two lasso lasso0..lasso7"""
import sys, math, random

R = (0.20, 1.30, -0.30, 20, 0)
OUT = (0.25, 1.40, -0.55, 30, 0)   # arm's length, the handle level

# one deliberate crack: rest -> wind-up over the shoulder -> hold -> fast forward swing -> follow-through -> rest
SWING = [
    (0, 0.20, 1.30, -0.30, 20, 0),
    (14, 0.24, 1.78, 0.08, 150, 0),
    (20, 0.24, 1.80, 0.10, 155, 0),
    (23, 0.22, 1.60, -0.35, 60, 0),
    (25, 0.20, 1.40, -0.55, 0, 0),
    (34, 0.20, 1.35, -0.50, 10, 0),
    (60, 0.20, 1.30, -0.30, 20, 0),
]


def key(t, ks):
    if t <= ks[0][0]:
        return ks[0][1:]
    for a, b in zip(ks, ks[1:]):
        if a[0] <= t <= b[0]:
            u = (t - a[0]) / (b[0] - a[0]) if b[0] > a[0] else 0
            return tuple(a[i] + (b[i] - a[i]) * u for i in range(1, 6))
    return ks[-1][1:]


def pose(p, left=False):
    x, y, z, pi, yw = p
    if left:
        x, yw = -x, -yw
    return '%s "%.3f %.3f %.3f %.2f %.2f 0"' % ('qz_lhand' if left else 'qz_rhand', x, y, z, pi, yw)


def pre(scen, extra=''):
    return ('vid_maxfps 35; wait 5; god; notarget; %s; %s; wait 70; %s use RSQWP_WhipWeapon; wait 60; rsqwp_debug 1; whp_scen %d; '
            'whp_metric 1; netevent whp_go; ' % (pose(R), pose((0.20, 1.30, -0.30, 20, 0), True), extra, scen))


def run(scen, hand='r'):
    left = hand == 'l'
    out = []
    if scen == 'snap':
        # the hand held out at arm's length, still; a 45-degree snap at t80 (then t120 back, t160, t200 back)
        out.append(pre(1).replace(pose(R), pose(OUT)))
        for t in range(340):
            if t in (80, 160): out.append('qz_rstick "1 0";')
            if t in (120, 200): out.append('qz_rstick "-1 0";')
            if t in (82, 122, 162, 202): out.append('qz_rstick "0 0";')
            out.append('wait 1;')
    elif scen == 'walk':
        out.append(pre(2))
        for t in range(340):
            if t == 80: out.append('qz_lstick "0 1";')
            if t == 185: out.append('qz_lstick "0 0";')
            out.append('wait 1;')
    elif scen == 'swing':
        out.append(pre(3))
        ks1 = [(k[0] + 60,) + k[1:] for k in SWING]
        ks2 = [(k[0] + 160,) + k[1:] for k in SWING]
        for t in range(270):
            out.append(pose(key(t, ks1 if t < 150 else ks2), left) + '; wait 1;')
    elif scen in ('yank', 'mark'):
        out.append(pre(4, 'netevent whp_summon 0 %d %d;' % (200, 0)))
        ks = [(k[0] + 40,) + k[1:] for k in SWING]
        pull = 0.6
        for t in range(240):
            if t == 20: out.append('qz_rtrigger 1;')
            if t == 170: out.append('qz_rtrigger 0;')
            if t < 110:
                p = key(t, ks)
            else:
                u = min(1.0, (t - 110) / 4.0)
                p = (0.20, 1.30, -0.40 + pull * u, 20, 0)
            out.append(pose(p, left) + '; wait 1;')
    elif scen.startswith('lasso'):
        # the left hand comes to the handle, grips at t15, whirls overhead (0.30 m circle, 14 tics a turn) to t150.
        # lasso0..lasso7: the circle started k x 45 degrees on, so the let-go at t150 is at that point of the circle
        ph = 45.0 * int(scen[5:]) if scen[5:] else 0.0

        out.append(pre(7))
        for t in range(210):
            if t == 15: out.append('qz_lgrip 1;')
            if t == 150: out.append('qz_lgrip 0;')
            if t < 10: lp = (-0.20, 1.20, -0.30, 0, 0)
            elif t < 20: lp = (0.20, 1.31, -0.50, 0, 0)
            elif t < 150:
                th = (t - 20) * 360.0 / 14.0 + ph; r = min(0.30, 0.03 * (t - 20))
                lp = (0.15 + r * math.cos(math.radians(th)), 1.70, -0.45 + r * math.sin(math.radians(th)), 0, 0)
            else: lp = (-0.20, 1.20, -0.30, 0, 0)
            x, y, z, pi, yw = lp
            out.append('qz_lhand "%.3f %.3f %.3f %.2f %.2f 0"; wait 1;' % (x, y, z, pi, yw))
    elif scen in ('coil', 'coilv'):
        # THE COIL (11-02): held still and coiled (t0-59), one deliberate wind-up + crack (t60), then the hand still
        # again so the whip goes quiet and reels back into the coil (to t259). coilv: the same with the arm 0.25 m
        # further out to the side, so a chase camera behind the body sees the coil at the hand (frames)
        dx = 0.25 if scen == 'coilv' else 0.0
        out.append(pre(3).replace(pose(R), pose((R[0] + dx,) + R[1:])))
        ks1 = [(k[0] + 60, k[1] + dx) + k[2:] for k in SWING]
        for t in range(260):
            out.append(pose(key(t, ks1), left) + '; wait 1;')
    elif scen == 'idle':
        out.append(pre(6))
        for t in range(340): out.append('wait 1;')
    elif scen == 'sway':
        # a slow sweep: the arm swings +-40 degrees of yaw over 4 s (twice), the hand moving with it
        out.append(pre(8))
        for t in range(340):
            a = 40 * math.sin(max(0, t - 60) * 2 * math.pi / 140) if t >= 60 else 0
            x = 0.20 + 0.15 * math.sin(math.radians(-a))
            out.append(pose((x, 1.35, -0.40, 5, a), left) + '; wait 1;')
    elif scen == 'jitter':
        # a jittery hand: the rest pose with noise (5 mm, 1.5 degrees a tic, seeded), then the same noisy wind-up + swing
        rnd = random.Random(7)
        out.append(pre(9))
        ks1 = [(k[0] + 160,) + k[1:] for k in SWING]
        for t in range(340):
            p = key(t, ks1) if t >= 160 else R
            n = [rnd.gauss(0, 0.005) for _ in range(3)] + [rnd.gauss(0, 1.5), rnd.gauss(0, 1.5)]
            out.append(pose(tuple(p[c] + n[c] for c in range(5)), left) + '; wait 1;')
    elif scen == 'two':
        # TWO WHIPS (the cost): the weapon whip in the main hand and the Whip (Off) bind held; both hands wind up and
        # swing (the off hand mirrored), twice; rsqwp_debug 3 logs the handler's ms a tic (T_WPWMS, every 70 tics)
        out.append(pre(3, '+rsqwp_off; wait 10;').replace('rsqwp_debug 1', 'rsqwp_debug 3'))
        ks1 = [(k[0] + 60,) + k[1:] for k in SWING]
        ks2 = [(k[0] + 160,) + k[1:] for k in SWING]
        for t in range(340):
            p = key(t, ks1 if t < 150 else ks2)
            out.append(pose(p) + '; ' + pose(p, True) + '; wait 1;')
    elif scen == 'wall':
        # stood 40 units from a wall, facing it: two deliberate swings into it
        out.append(pre(10, 'netevent whp_facewall 40; wait 3;'))
        ks1 = [(k[0] + 60,) + k[1:] for k in SWING]
        ks2 = [(k[0] + 160,) + k[1:] for k in SWING]
        for t in range(340):
            out.append(pose(key(t, ks1 if t < 150 else ks2), left) + '; wait 1;')
    out.append('quit')
    return ' '.join(out)


if __name__ == '__main__':
    print(run(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else 'r'))
