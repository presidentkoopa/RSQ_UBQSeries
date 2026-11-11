# TEST ONLY (scratch, rig1110, group P2): console-script builder for the P2 launches.
class S:
    def __init__(s): s.c = []
    def add(s, *cmds): s.c += list(cmds)
    def w(s, n): s.c.append('wait %d' % n)
    def r(s, x, y, z, p=30, yw=0, rl=0): s.c.append('qz_rhand "%.3f %.3f %.3f %g %g %g"' % (x, y, z, p, yw, rl))
    def l(s, x, y, z, p=30, yw=0, rl=0): s.c.append('qz_lhand "%.3f %.3f %.3f %g %g %g"' % (x, y, z, p, yw, rl))
    def swing(s, hand, step, x=0.25, y=1.35, z0=-0.15, n=7):
        # straight forward (-z) at `step` m a tic (0.057 = 2.0 m/s, 0.086 = 3.0 m/s), one pose a tic, as L8
        for k in range(n):
            (s.r if hand == 'r' else s.l)(x, y, z0 - step * k); s.w(1)
    def text(s): return '; '.join(s.c)
