"""TEST ONLY: break-open reloads in the rig -- open, take a round, seat it in each empty chamber, flick shut."""
import re, sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
import numpy as np, rig, handrot as h
FAR = '-0.25 1.3 -0.3 30 0 0'
RH = '0.25 1.3 -0.3 %s %s %s'
def chambers(c):
    t = open(rig.OUT + '/open_%s.log' % c, errors='replace').read()
    m = re.search(r'B22 BREAK gun (\d+) nch (\d+) theta \S+ hb (\S+) (\S+) (\S+) ht (\S+) (\S+) (\S+)', t)
    hb = np.array([float(x) for x in m.group(3, 4, 5)]); ht = np.array([float(x) for x in m.group(6, 7, 8)])
    ch = [(np.array([float(x) for x in a[0:3]]), np.array([float(x) for x in a[3:6]]), float(a[6]))
          for a in re.findall(r'B22 CH \d+ tip (\S+) (\S+) (\S+) bore (\S+) (\S+) (\S+) depth (\S+)', t)]
    return hb, ht, ch
def run(c, ammo, flick):
    hb, ht, ch = chambers(c)
    load = ''
    for tk, bk, dep in ch:
        a = ht - hb
        p1 = h.place(ht, a, tk - bk * (dep + 1.0), bk)[0]
        p2 = h.place(ht, a, tk - bk * (dep * 0.5), bk)[0]
        p3 = h.place(ht, a, tk, bk)[0]
        load += ('qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 10; qz_lhand "%s"; wait 12; qz_lhand "%s"; wait 10; '
                 'qz_lhand "%s"; wait 15; qz_ltrigger 0; wait 10; ' % (FAR, p1, p2, p3))
    s = ('wait 120; god; rsq_extra_weapons 1; rsb_revolver_feed %s; rsr_reload 1;' % __import__('os').environ.get('FEED','0') + (' rsr_debug 1; give %s; give %s 100; use %s; wait 90; '
         '+attack; wait 3; -attack; wait 30; +attack; wait 3; -attack; wait 40; +reload; wait 4; -reload; wait 30; %s qz_lhand "%s"; wait 10; '
         'qz_rhand "%s"; wait 4; qz_rhand "%s"; wait 40; quit'
         % (c, ammo, c, load, FAR, RH % flick, RH % (30, 0, 0))))
    rig.run('brk_%s' % c, s, 260)
    t = open(rig.OUT + '/brk_%s.log' % c, errors='replace').read()
    return [l for l in t.splitlines() if re.match(r'rsb t', l)]
if __name__ == '__main__':
    c, ammo = sys.argv[1], sys.argv[2]
    flick = tuple(float(x) for x in sys.argv[3:6]) if len(sys.argv) > 5 else (70, 0, 0)
    for l in run(c, ammo, flick): print(l[:150])
