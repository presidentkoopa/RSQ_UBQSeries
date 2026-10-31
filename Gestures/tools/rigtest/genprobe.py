"""TEST ONLY: writes gprobe/zscript.txt's keyframe table from motions written in AIM terms
(x y z stage metres; aim pitch up, aim yaw left, twist about the pointing axis), converted to the rig's
stage controller angles by aim2stage.py. Left-hand rows are written as the hand itself (mirror numbers)."""
import re, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from aim2stage import stage

AIM  = (0.20, 1.35, -0.40, 0, 0, 0)
RAISE = (0.08, 1.50, -0.35, 25, 0, 0)
def tw(p, w): return p[:5] + (w,)
LREST = (-0.25, 1.30, -0.30, 0, 0, 0)
RREST = (0.25, 1.30, -0.30, 0, 0, 0)
def mirror(p): return (-p[0], p[1], p[2], p[3], -p[4], -p[5])

M = {}
seq1 = [(0, AIM), (30, AIM), (42, RAISE), (50, RAISE), (56, tw(RAISE, 70)), (100, tw(RAISE, 70)),
        (106, RAISE), (125, RAISE), (131, tw(RAISE, 70)), (165, tw(RAISE, 70)),
        (175, (0.12, 1.10, -0.30, 25, 0, 70)), (195, (0.12, 1.10, -0.30, 25, 0, 70)), (205, AIM), (240, AIM)]
M[1] = {0: seq1, 1: [(0, LREST), (240, LREST)]}
M[2] = {1: [(t, mirror(p)) for t, p in seq1], 0: [(0, RREST), (240, RREST)]}
M[3] = {0: [
    (0, AIM), (20, (0.25, 1.38, -0.42, 15, 40, 25)), (40, (0.15, 1.32, -0.42, -10, -40, -25)),
    (60, (0.22, 1.45, -0.40, 25, 30, 20)), (80, (0.18, 1.30, -0.40, -5, -30, -25)), (100, AIM),
    # aim down the sights
    (110, (0.04, 1.52, -0.30, 0, 0, 5)), (150, (0.04, 1.52, -0.30, 0, 0, 5)),
    # reload at the chest, gun twisted 60 to show the magwell, held while the other hand works
    (165, (0.15, 1.12, -0.30, 25, 20, 60)), (215, (0.15, 1.12, -0.30, 25, 20, 60)), (230, AIM),
    # a fast roll flick at face height (racking, a shake): 3 tics over the threshold
    (245, (0.10, 1.48, -0.35, 20, 0, 0)), (250, (0.10, 1.48, -0.35, 20, 0, 0)), (252, (0.10, 1.48, -0.35, 20, 0, 80)),
    (255, (0.10, 1.48, -0.35, 20, 0, 80)), (257, (0.10, 1.48, -0.35, 20, 0, 0)), (270, AIM),
    # a fast swing through the pose with the wrist turned (a melee swipe)
    (280, (0.50, 1.30, -0.10, 0, -60, 70)), (285, (0.50, 1.30, -0.10, 0, -60, 70)),
    (290, (-0.10, 1.55, -0.40, 0, 40, 70)), (295, (-0.10, 1.55, -0.40, 0, 40, 70)), (305, AIM),
    # canted aim: the gun on its side at the shoulder line, pointed forward
    (320, (0.15, 1.42, -0.40, 0, 0, 80)), (360, (0.15, 1.42, -0.40, 0, 0, 80)), (370, AIM), (400, AIM)],
    1: [(0, LREST), (165, LREST), (180, (0.05, 1.10, -0.25, 0, 20, 0)), (210, (0.05, 1.10, -0.25, 0, 20, 0)),
        (230, LREST), (400, LREST)]}
s4r = [(0, RAISE), (20, RAISE), (26, tw(RAISE, 70)), (50, tw(RAISE, 70)), (56, RAISE), (70, RAISE),
       (76, tw(RAISE, -70)), (100, tw(RAISE, -70)), (106, RAISE), (110, AIM), (240, AIM)]
s4l = [(0, LREST), (110, LREST), (120, mirror(RAISE)), (130, mirror(RAISE)), (136, mirror(tw(RAISE, 70))),
       (160, mirror(tw(RAISE, 70))), (166, mirror(RAISE)), (180, mirror(RAISE)), (186, mirror(tw(RAISE, -70))),
       (210, mirror(tw(RAISE, -70))), (216, mirror(RAISE)), (240, mirror(RAISE))]
M[4] = {0: s4r, 1: s4l}
# one hand and both hands: thrust, pull, both down, apart, palms out, rifle hold
PALM = (0.20, 1.45, -0.45, 55, 0, 0)
RIFLE_R = (0.15, 1.35, -0.30, 0, 0, 0); RIFLE_L = (-0.12, 1.40, -0.65, 0, 0, 0)
M[6] = {0: [(0, AIM), (20, AIM), (23, (0.20, 1.37, -0.80, 0, 0, 0)), (40, (0.20, 1.37, -0.80, 0, 0, 0)), (60, AIM),
            (63, (0.20, 1.35, -0.05, 0, 0, 0)), (80, (0.20, 1.35, -0.05, 0, 0, 0)), (100, (0.20, 1.30, -0.30, 0, 0, 0)),
            (110, (0.20, 1.30, -0.30, 0, 0, 0)), (114, (0.25, 0.85, -0.20, -40, 0, 0)), (140, (0.25, 0.85, -0.20, -40, 0, 0)),
            (150, (0.05, 1.25, -0.30, 0, 0, 0)), (160, (0.05, 1.25, -0.30, 0, 0, 0)), (164, (0.55, 1.25, -0.30, 0, 0, 0)),
            (180, (0.55, 1.25, -0.30, 0, 0, 0)), (190, PALM), (240, PALM), (246, (0.20, 1.40, -0.40, 0, 0, 0)), (256, RIFLE_R), (300, RIFLE_R)],
         1: [(0, LREST), (110, (-0.20, 1.30, -0.30, 0, 0, 0)), (114, (-0.25, 0.85, -0.20, -40, 0, 0)),
             (140, (-0.25, 0.85, -0.20, -40, 0, 0)), (150, (-0.05, 1.25, -0.30, 0, 0, 0)), (160, (-0.05, 1.25, -0.30, 0, 0, 0)),
             (164, (-0.55, 1.25, -0.30, 0, 0, 0)), (180, (-0.55, 1.25, -0.30, 0, 0, 0)), (190, mirror(PALM)), (240, mirror(PALM)),
             (246, (-0.20, 1.40, -0.40, 0, 0, 0)), (256, RIFLE_L), (300, RIFLE_L)]}

rows = []
for m in sorted(M):
    for h in (0, 1):
        for t, p in M[m][h]:
            x, y, z, ap, ay, w = p
            if h == 0:
                sp, sy, sr = stage(ap, ay, w)
            else:
                sp, sy, sr = stage(ap, -ay, -w); sy, sr = -sy, -sr
            rows.append('\t\t%d,%d,%4d, %.3f,%.3f,%.3f, %.2f,%.2f,%.2f' % (m, h, t, x, y, z, sp, sy, sr))
f = os.path.join(os.path.dirname(os.path.abspath(__file__)), "gprobe", "zscript.txt")
s = open(f).read()
s = re.sub(r'static const double K\[\] = \{.*?\n\t\};', 'static const double K[] = {\n' + ',\n'.join(rows) + '\n\t};', s, flags=re.S)
open(f, 'w').write(s)
print(len(rows), 'rows')
