#!/usr/bin/env python3
"""TEST ONLY (never ships). Console scripts for the 11-13 control change (Whip README, Lock-On Controls):
On a Rope, Jump Lets Go (rsqwp_rope_jump) and Crack at Gold (rsqwp_lock_goldcrack), on SWINGTST with the whp probe
(scenario 11: whp_S / whp_H a tic). Lock-On Controls on (the default). The whip hand (right) aims the ray itself.

    python3 lock1113.py <scenario>      prints the script
scenarios:
  gold    on A's lip facing the pit, the ray gold on the pit's ceiling, no alt-fire: one crack (snags, waits); +jump
          t80 (the start: must not let go); alt-fire held t120-t150 (nothing); trigger held t165-t215 (reels);
          +jump t240 (lets go)
  old     the same with rsqwp_rope_jump 0 set first: jump t80 starts; jump t120 nothing; alt-fire held t140-t170
          reels; the trigger pressed t190 lets go
  mark    on A facing its south wall (gold, ~11 m), an imp 150 ahead on the line; the trigger pressed t5 marks it;
          one crack: it flies to the imp, not the wall
  inway   the same, no trigger: one crack with the imp in the way (an ordinary crack); then the player steps 96 east
          off the imp's line (t100) and cracks again at the same wall (snags it)
"""
import math, sys

import os
YAW = float(os.environ.get('YAW', '-90'))
PITCH_FIX = 30.0      # the rig's controller pitch reads ~this much lower than the pose's (whp_scripts.py)


def hand(x, y, z, pitch, yaw=0.0):
    return 'qz_rhand "%.3f %.3f %.3f %.2f %.2f 0"' % (x, y, z, pitch, yaw)


def turn(x, z, yaw):
    """a stage point (x right, z back) turned by the view's yaw (degrees, + to the left)"""
    c, s = math.cos(math.radians(yaw)), math.sin(math.radians(yaw))
    return x * c + z * s, -x * s + z * c


def crack_keys(aim, start, yaw=0.0):
    """aim pose -> wind-up over the shoulder -> hold -> fast forward swing -> follow-through -> back to the aim; the
    whole gesture turned with the view (yaw)"""
    c3, c4, c5 = [int(v) for v in os.environ.get('CK', '23 25 34').split()]    # the swing's keys (CK: a slower swing)
    ks = [(14, 0.24, 1.78, 0.08, 150), (20, 0.24, 1.80, 0.10, 155), (c3, 0.22, 1.60, -0.35, 60),
          (c4, 0.20, 1.40, -0.55, 0), (c5, 0.20, 1.35, -0.50, 10)]
    out = [(start + 0,) + aim]
    for t, x, y, z, p in ks:
        tx, tz = turn(x, z, yaw)
        out.append((start + t, tx, y, tz, p, yaw))
    out.append((start + 60,) + aim)
    return out


def key(t, ks):
    if t <= ks[0][0]:
        return ks[0][1:]
    for a, b in zip(ks, ks[1:]):
        if a[0] <= t <= b[0]:
            u = (t - a[0]) / (b[0] - a[0]) if b[0] > a[0] else 0
            return tuple(a[i] + (b[i] - a[i]) * u for i in range(1, 6))
    return ks[-1][1:]


def build(scen):
    ev = {}
    def at(t, c): ev.setdefault(t, []).append(c)
    cracks = []
    T = 200
    if scen in ('gold', 'old', 'step'):
        aim = (0.20, 1.30, -0.30, 13 + PITCH_FIX, 0)      # the pit's ceiling, ~8 m out (whp_scripts ceil: pitch 13)
        at(0, 'netevent whp_tp 378 512 0')
        cracks.append(20)
        if scen == 'step':
            # no jump to start: a step off the lip (the stick), then the first Jump in the air
            at(80, 'qz_lstick "0 1"'); at(96, 'qz_lstick "0 0"')
            at(140, '+jump'); at(143, '-jump')
            at(200, '+jump'); at(203, '-jump')
            T = 230
        elif scen == 'gold':
            at(80, '+jump'); at(83, '-jump')
            at(120, '+altattack'); at(150, '-altattack')
            at(165, 'qz_rtrigger 1'); at(215, 'qz_rtrigger 0')
            at(240, '+jump'); at(243, '-jump')
            T = 280
        else:
            at(80, '+jump'); at(83, '-jump')
            at(120, '+jump'); at(123, '-jump')
            at(140, '+altattack'); at(170, '-altattack')
            at(190, 'qz_rtrigger 1'); at(194, 'qz_rtrigger 0')
            T = 230
    elif scen == 'mark2':
        # the mark on the imp, then the hand (and the view) turned 30 degrees to the right on A's west wall (gold, the imp
        # well off that line): the crack still flies to the marked imp
        def aimat(yaw):
            ax, az = turn(0.20, -0.30, yaw)
            return (ax, 1.30, az, 0 + PITCH_FIX, yaw)
        aim = aimat(-90)
        at(0, 'netevent whp_tp 200 400 0'); at(0, 'qz_hmd "0 1.6 0 0 -90 0"')
        at(4, 'netevent whp_summon 0 150 0')
        at(6, 'qz_rtrigger 1'); at(9, 'qz_rtrigger 0')
        aim2 = aimat(-120)
        at(12, 'qz_hmd "0 1.6 0 0 -120 0"')
        swap = (12, aim2)
        cracks.append(40)
        T = 140
    elif scen in ('mark', 'inway'):
        # level, at A's south wall: the view and the hand turned to it (the body follows the view)
        yaw = YAW
        ax, az = turn(0.20, -0.30, yaw)
        aim = (ax, 1.30, az, 0 + PITCH_FIX, yaw)
        at(0, 'netevent whp_tp 200 400 0'); at(0, 'qz_hmd "0 1.6 0 0 %.1f 0"' % yaw)
        at(4, 'netevent whp_summon 0 150 0')
        if scen == 'mark':
            at(6, 'qz_rtrigger 1'); at(9, 'qz_rtrigger 0')
            cracks.append(24)
            T = 120
        else:
            cracks.append(24)
            at(100, 'netevent whp_tp 296 400 0')
            cracks.append(120)
            T = 220
    else:
        sys.exit('unknown scenario ' + scen)
    swap = locals().get('swap')
    aims = lambda t: swap[1] if swap and t >= swap[0] else aim
    ks = [crack_keys(aims(c), c, aims(c)[4]) for c in cracks]
    out = ['vid_maxfps 35; wait 5; god; notarget; %s; qz_lhand "-0.20 1.30 -0.30 20 0 0"; wait 70; use RSQWP_WhipWeapon; wait 60; '
           'rsqwp_debug 1; whp_scen 11; netevent whp_go;' % hand(*aim)]
    for t in range(T):
        for c in ev.get(t, []):
            out.append(c + ';')
        p = aims(t)
        for k in ks:
            if t >= k[0][0]:
                p = key(t, k)
        out.append(hand(*p) + '; wait 1;')
    out.append('wait 10; quit')
    return ' '.join(out)


if __name__ == '__main__':
    print(build(sys.argv[1]))
