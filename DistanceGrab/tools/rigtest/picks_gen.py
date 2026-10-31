import sys
# picks_gen.py <test>  -> writes <test>.cmd, a console script for picks_rig.sh (TEST ONLY; owner picks 19-24, 2026-10-31).
# MAP01 drops down steps ~40 units ahead of the start: a walking monster placed past them stands 48 lower, so the
# hit-stop target is a Cacodemon (it floats at the spawn height).
def R(x, z, p=-11, y=-30, r=90): return 'qz_rhand "%g 1.3 %g %g %g %g"' % (x, z, p, y, r)
def L(x, z, p=-11, y=30, r=-90): return 'qz_lhand "%g 1.3 %g %g %g %g"' % (x, z, p, y, r)
def W(n): return 'wait %d' % n
t = sys.argv[1]
s = []
if t == 'swing':
    s += ['rsqdgt_every 1', L(-0.5, 0.2), R(0.25, -0.3), 'rsqdgt_scene "ExplosiveBarrel:22:8,HellKnight:44:44"', W(60), 'netevent rsqdg_ngrip 0 1', W(30)]
    for k in range(2):
        s += [R(0.1, -0.3), W(3), R(-0.05, -0.3), W(3), R(-0.2, -0.3), W(3), R(-0.35, -0.3), W(30)]
        x = -0.35
        while x < 1.0:
            x += 0.15; s += [R(x, -0.3), W(1)]
        s += [W(30), R(0.8, -0.3), W(5), R(0.6, -0.3), W(5), R(0.4, -0.3), W(5), R(0.25, -0.3), W(40)]
    # the throw: a slow wind-up back, then a fast forward move
    s += [R(0.25, -0.2), W(4), R(0.25, -0.1), W(4), R(0.25, 0.0), W(4), R(0.25, 0.1), W(6),
          R(0.25, -0.2), W(1), R(0.25, -0.5), W(1), R(0.25, -0.8), W(80)]
elif t == 'collar':
    extra = sys.argv[2] if len(sys.argv) > 2 else ''
    s += [extra, L(-0.25, -0.3), R(0.25, -0.3, r=0), 'rsqdgt_scene "Zombieman:30:-9,HellKnight:95:-6"', W(60), 'netevent rsqdg_ngrip 1 1', W(30)]
    s += [L(-0.25, -0.2), W(4), L(-0.25, -0.1), W(4), L(-0.25, 0.0), W(4), L(-0.25, 0.1), W(6),
          L(-0.25, -0.2), W(1), L(-0.25, -0.5), W(1), L(-0.25, -0.8), W(1), L(-0.25, -0.8), W(120), 'netevent rsqdg_ngrip 1 0', W(10)]
elif t == 'hitstop':
    s += ['rsqdg_hitstop 4', 'rsqdgt_every 1', 'rsqdg_throw_assist 0', R(0.25, -0.3), 'rsqdgt_scene "ExplosiveBarrel:22:8,Cacodemon:110:0"', W(60), 'netevent rsqdg_ngrip 0 1', W(30),
          R(0.25, -0.2), W(4), R(0.25, -0.1), W(4), R(0.25, 0.0), W(4), R(0.25, 0.1), W(6),
          R(0.25, -0.2), W(1), R(0.25, -0.5), W(1), R(0.25, -0.8), W(120)]
elif t == 'switch':
    s += ['rsqdgt_every 1', R(0.25, -0.3, r=0), 'rsqdgt_switch 40', W(80), R(0.25, -0.3), W(60)]
s = [x for x in s if x]
open(t + '.cmd', 'w').write('; '.join(s))
print('; '.join(s))
