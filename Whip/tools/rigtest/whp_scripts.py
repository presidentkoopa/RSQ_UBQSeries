#!/usr/bin/env python3
"""TEST ONLY (never ships). Console scripts for tools/rigtest/whp.sh: one tic per `wait 1` (vid_maxfps 35 gives
the rig exactly one frame a tic -- measured: whp_F frame n = gametic n+1). The rig's controller cvars can only be
set from the console (a play-scope CVar.SetString on an engine cvar aborts), so the hand is driven here.

    python3 tools/rigtest/whp_scripts.py <scenario> [hand]     prints the script
scenarios: snap walk swing coil yank hands idle mark sway jitter wall two lasso lasso0..lasso7
the aimed swing (swing.zs) on SWINGTST (mkswingmap.py; whp.sh with PRE=<the wad>): aim ceil wallanchor chain refuse snag"""
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
    if scen in SWINGS:
        out.append(pre_swing())
        out.extend(swing_scen(scen))
    elif scen == 'snap':
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
    elif scen.startswith('crackhit'):
        # KNOCKBACK CHECK (11-03): a monster summoned CH_DIST ahead (CH_CLS 0 imp, 1 zombieman, 2 demon); two plain
        # wind-up + cracks into it (no trigger: no mark); 'crackhitm': the trigger held from t20 to t170 (the mark: the
        # crack flies to it, wraps; the arm then sways +-40 deg, as a real arm moves after a crack)
        import os
        d = int(os.environ.get('CH_DIST', '64')); c = int(os.environ.get('CH_CLS', '0'))
        held = scen == 'crackhitm'
        off = scen == 'crackhito'   # the Whip (Off) bind in the left hand, the load order's own gun in the main hand
        out.append(pre(12, 'netevent whp_summon %d %d 0;' % (c, d)))
        if off: out[-1] = out[-1].replace('use RSQWP_WhipWeapon;', '+rsqwp_off; wait 10;')
        ks1 = [(k[0] + 40,) + k[1:] for k in SWING]
        ks2 = [(k[0] + 180,) + k[1:] for k in SWING]
        for t in range(300):
            if held and t == 20: out.append('qz_rtrigger 1;')
            if held and t == 170: out.append('qz_rtrigger 0;')
            if held and 100 <= t < 170:
                a = 40 * math.sin((t - 100) * 2 * math.pi / 35)
                p = (0.20 + 0.15 * math.sin(math.radians(-a)), 1.35, -0.40, 5, a)
            else:
                p = key(t, ks1 if t < 170 else ks2)
            out.append(pose(p, left or off) + '; wait 1;')
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


# ---- THE AIMED SWING (swing.zs) on SWINGTST ------------------------------------------------------------------------
SWINGS = ('aim', 'ceil', 'wallanchor', 'chain', 'refuse', 'snag')
LREST = (-0.20, 1.30, -0.30, 20, 0)
PITCH_FIX = 30.0   # the rig's controller pitch reads ~this much lower than the pose's (measured: 35 -> ~3, 45 -> ~13)
RELEASE_CEIL = 92
WALL_YAW = -11.0
import os
CHAIN_REL = [int(x) for x in os.environ.get('CHAIN_REL', '98 129 151').split()]       # the let-go tics (tuned on the rig)
CHAIN_PITCH = [float(x) for x in os.environ.get('CHAIN_PITCH', '54 54 54').split()]  # the ray's pitch for each next cast


def lpose(pitch, yaw=0.0, x=-0.20, y=1.40, z=-0.40):
    return 'qz_lhand "%.3f %.3f %.3f %.2f %.2f 0"' % (x, y, z, pitch + PITCH_FIX, yaw)


def hmd(pitch, yaw):
    return 'qz_hmd "0 1.6 0 %.2f %.2f 0"' % (pitch, yaw)


def pre_swing(extra=''):
    return ('vid_maxfps 35; wait 5; map SWINGTST; wait 40; god; notarget; %s; %s; wait 70; use RSQWP_WhipWeapon; wait 60; '
            'rsqwp_debug 1; whp_scen 11; whp_log 3; %s netevent whp_go; ' % (pose(R), pose(LREST, False).replace('qz_rhand', 'qz_lhand'), extra))


def swing_scen(scen):
    """tic-by-tic commands (ev), and the whip hand's crack windows (each a SWING from its start tic)"""
    ev = {}
    def at(t, c): ev.setdefault(t, []).append(c)
    cracks = []
    T = 240
    if scen == 'aim':
        # the ray, valid and refused: the pit's ceiling (valid), A's floor (floor), level east (out of reach), the
        # pit's south wall (valid wall), the sky yard's ceiling (sky). The view turns with the ray (qz_hmd).
        at(5, '+oh_altatk')
        at(5, lpose(35)); at(40, lpose(-50)); at(70, lpose(2))
        at(100, 'netevent whp_tp 360 200 0'); at(101, lpose(12, -60)); at(101, hmd(0, -60))
        at(135, 'netevent whp_tp 192 900 0'); at(136, lpose(45, 90)); at(136, hmd(30, 90))
        at(170, '-oh_altatk'); at(170, hmd(0, 0))
        T = 200
    elif scen == 'ceil':
        # ceiling anchor -> hop -> swing -> release -> carried arc and landing. At the ledge's lip facing east, the ray
        # on the pit's ceiling ~9 m out, one crack; a step off the lip (stick, 3 tics) after the latch; let go (the whip
        # hand's alt-fire) on the upswing; land on M
        at(0, 'netevent whp_tp 378 512 0')
        at(5, '+oh_altatk'); at(5, lpose(13))
        cracks.append(20)
        at(60, '-oh_altatk')
        at(52, 'qz_lstick "0 1"'); at(55, 'qz_lstick "0 0"')
        at(RELEASE_CEIL, '+altattack'); at(RELEASE_CEIL + 2, '-altattack')
        T = 220
    elif scen == 'wallanchor':
        # wall anchor -> a sideways arc: at the lip near the south wall, the ray on the wall to the right and ahead;
        # a step off the lip after the latch; it swings round the point on the wall; let go late
        at(0, 'netevent whp_tp 378 36 0')
        at(5, '+oh_altatk'); at(5, lpose(6, WALL_YAW))
        cracks.append(20)
        at(60, '-oh_altatk')
        at(64, 'qz_lstick "0 1"'); at(76, 'qz_lstick "0 0"')     # after the hop has landed: a step off the lip
        at(200, '+altattack'); at(202, '-altattack')
        T = 240
    elif scen == 'snag':
        # the old edge snag, no ray: stood under the A/P lintel (its edge at z 192, x 384), one wind-up and crack
        at(0, 'netevent whp_tp 372 512 0')
        cracks.append(20)
        T = 120
    elif scen == 'refuse':
        # the ray held on the sky, then on the floor, and a crack each time: an ordinary crack, no rope
        at(0, 'netevent whp_tp 192 900 0')
        at(5, '+oh_altatk'); at(5, lpose(45, 90))
        cracks.append(20)
        at(100, 'netevent whp_tp 300 512 0'); at(100, lpose(-50))
        cracks.append(110)
        at(190, '-oh_altatk')
        T = 200
    elif scen == 'chain':
        # swings across the 45 m pit: cast, step off, swing; on the upswing let go with the whip wound up (raised
        # over the shoulder while still on the rope), crack again in the air at the next spot ahead, and so on
        at(0, 'netevent whp_tp 378 512 0')
        at(5, '+oh_altatk'); at(5, lpose(13))
        cracks.append(20)
        at(52, 'qz_lstick "0 1"'); at(55, 'qz_lstick "0 0"')
        for k, rt in enumerate(CHAIN_REL):
            at(rt, '+altattack'); at(rt + 2, '-altattack')
            at(rt - 10, lpose(CHAIN_PITCH[k]))
            if k < len(CHAIN_REL) - 1:
                cracks.append(rt - 14)    # the wind-up starts on the rope (14 tics up, held), the swing after the let-go
        at(CHAIN_REL[-1] + 40, '-oh_altatk')
        T = CHAIN_REL[-1] + 140
    out = []
    for t in range(T):
        for c in ev.get(t, []): out.append(c + ';')
        p = R
        for c in cracks:
            if t >= c: p = key(t, [(k[0] + c,) + k[1:] for k in SWING])
        out.append(pose(p) + '; wait 1;')
    return out


if __name__ == '__main__':
    print(run(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else 'r'))
