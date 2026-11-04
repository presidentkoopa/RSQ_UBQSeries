import sys
# wseq.py <scene: idle|windup|crack|full> <lefty 0/1> <cam eye|side> -> console script ending on the frame to look at
scene, lefty, cam = sys.argv[1], sys.argv[2] == '1', sys.argv[3]
M = 'qz_lhand' if lefty else 'qz_rhand'; O = 'qz_rhand' if lefty else 'qz_lhand'; sx = -1 if lefty else 1
def P(x, y, z, p, yw): return '"%.3f %.3f %.3f %.2f %.2f 0"' % (x * sx, y, z, p, yw * sx)
SWING = [(0, 0.20, 1.30, -0.30, 20, 0), (14, 0.24, 1.78, 0.08, 150, 0), (20, 0.24, 1.80, 0.10, 155, 0),
         (23, 0.22, 1.60, -0.35, 60, 0), (25, 0.20, 1.40, -0.55, 0, 0), (34, 0.20, 1.35, -0.50, 10, 0), (60, 0.20, 1.30, -0.30, 20, 0)]
def key(t):
    for a, b in zip(SWING, SWING[1:]):
        if a[0] <= t <= b[0]:
            u = (t - a[0]) / (b[0] - a[0]); return tuple(a[i] + (b[i] - a[i]) * u for i in range(1, 6))
    return SWING[-1][1:]
hmd = {'eye': '"0 1.6 0 -10 0 0"', 'up': '"0 1.6 0 35 0 0"', 'side': '"%.2f 1.55 -0.25 -10 %d 0"' % (0.62 * sx, 90 * sx)}[cam]
s = (['vr_control_scheme 10'] if lefty else []) + ['qz_hmd %s' % hmd, '%s %s' % (M, P(*SWING[0][1:])), '%s %s' % (O, P(-0.20, 1.30, -0.30, 20, 0)),
     'wait 40', 'use RSQWP_WhipWeapon', 'wait 70', 'rsqwp_debug 1', 'echo HH_GO']
end = {'idle': 0, 'windup': 20, 'swing': 23, 'crack': 27, 'full': 60}[scene]
for t in range(end + 1):
    s += ['%s %s' % (M, P(*key(t))), 'wait 1']
s += ['wait 20' if scene == 'full' else 'wait 1', 'quit']
print('; '.join(s))
