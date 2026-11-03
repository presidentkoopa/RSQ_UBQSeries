#!/usr/bin/env python3
# TEST ONLY. Writes trb_script.txt: the torso against looking down and nodding (11-03).
#  L: a LEVEL look held 60 degrees round for 2 s (the torso must still turn to it), then level ahead again until it is back.
#  D30 / D50 / D70: the head pitched 30 / 50 / 70 degrees down and held 60 degrees round for 2 s (old: the torso swings;
#  new: it does not).
#  N: a pure nod about a neck 0.10 m behind and 0.10 m under the eyes (the headset's place moves as a real nod moves it),
#  0 / 30 / 50 / 70 degrees down, each held 20 tics with a trb_rep line (old: the holsters move with the headset; new: ~0).
# The rig's qz_hmd is "x y z pitch yaw roll", metres (+x right, +y up, -z forward), pitch negative looking down (checked
# in the log: the pawn's pitch comes out positive).
import os, math
HERE = os.path.dirname(os.path.abspath(__file__))
def hmd(pitch_down, yaw, nod=False):
    x, y, z = 0.0, 1.6, 0.0
    if nod:
        t = math.radians(pitch_down)
        B = D = 0.10
        horiz = B * math.cos(t) + D * math.sin(t)
        vert = -B * math.sin(t) + D * math.cos(t)
        y = 1.5 + vert
        z = 0.10 - horiz
    return 'qz_hmd "%.4f %.4f %.4f %.1f %.1f 0"; ' % (x, y, z, -pitch_down, yaw)
s = 'wait 40; set rsqtr_messages 1; %swait 60; ' % hmd(0, 0)
k = 1
s += 'echo TRB_L_LEVEL_HELD_ROUND; set trb_rep %d; wait 1; %swait 70; set trb_rep %d; wait 1; %swait 100; set trb_rep %d; wait 1; ' % (k, hmd(0, 60), k + 1, hmd(0, 0), k + 2)
k += 3
for d in (30, 50, 70):
    s += 'echo TRB_D%d_DOWN_HELD_ROUND; set trb_rep %d; wait 1; %swait 70; set trb_rep %d; wait 1; %swait 100; set trb_rep %d; wait 1; ' % (d, k, hmd(d, 60), k + 1, hmd(0, 0), k + 2)
    k += 3
s += 'echo TRB_N_NOD; '
for d in (0, 30, 50, 70, 0):
    s += '%swait 20; set trb_rep %d; wait 1; ' % (hmd(d, 0, True), k)
    k += 1
s += 'wait 10; quit\n'
open(os.path.join(HERE, 'trb_script.txt'), 'w').write(s)
print(s)
