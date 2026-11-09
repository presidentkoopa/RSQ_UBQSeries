#!/usr/bin/env python3
"""THE AMMO POUCH'S REAL GRAB ZONE (owner 2026-11-09 17:26: "ammo pouch holster has to be reasonably bigger than the
grenade holster, maybe moved just a little to the left of its current spot").

    python3 tools/measure_pouch.py            # the pouch and the grenade spot as committed in zscript/rsqtr/rig.zs
    python3 tools/measure_pouch.py search     # also: candidate pouch spots, best first

PARSED, NOT COPIED: every place (RSQTR_Region DF / DL / DU / DR) from rig.zs, the cigarette pocket from cig.zs, the reach
assist's numbers (POUCH_REACH_M, POUCH_REACH_BAND) from rig.zs. Right-handed standing layout (RSQTR_Rig.Settings' "toward a
hand" flips: the whip's left toward the main hand; keyring, flare and pouch toward the off hand), BodyScale 1, Reach 1.

THE RULE IN PLAY (rig.zs WorldTick, the hover loop): a hand is in a place when it is within that place's radius of its
centre; inside two or more, the one the hand can use wins (OVERLAP PRIORITY, 11-08), and among equals the NEAREST CENTRE.
For the off hand going for a magazine every belt place usually "holds" something (grenades in the spot, guns in the
hips), so the measure here is the worst case: all equal, nearest centre wins. A place's EFFECTIVE ZONE is the volume of
points it wins. The keyring is no place outside edit mode (skipped); the saber spots, whip and flare are counted (worst
case: their mods loaded). The reach assist (rig.zs PouchReach) moves the pouch's centre toward the off hand by at most
POUCH_REACH_M while the hand is within radius + POUCH_REACH_BAND: its zone is measured as the union of the spheres the
centre can reach toward each point (a point at distance d from the base centre is won when d - shift(d) <= radius and
the moved centre is the nearest).
"""
import os, re, sys, math
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
RIG = os.path.join(ROOT, 'zscript', 'rsqtr', 'rig.zs')
CIG = os.path.join(ROOT, 'zscript', 'rsqtr', 'cig.zs')
NAMES = ["Left hip", "Right hip", "", "Grenades", "Left shoulder", "Right shoulder", "Left chest", "Right chest",
         "Keyring", "Left saber", "Right saber", "Whip", "Flare", "Ammo pouch"]
GREN, POUCH, KEYRING, WHIP = 3, 13, 8, 11


def table(src, name):
    m = re.search(r'static const double %s\[\]\s*=\s*\{([^}]*)\}' % name, src)
    return [float(x) for x in m.group(1).split(',')]


def const(src, name, default=None):
    m = re.search(r'const\s+%s\s*=\s*([-0-9.]+)' % name, src)
    return float(m.group(1)) if m else default


def places(src, cig):
    F, L, U, R = (table(src, k) for k in ('DF', 'DL', 'DU', 'DR'))
    L = list(L)
    L[WHIP] = -L[WHIP]          # right-handed: the whip's left is toward the MAIN hand
    out = []
    for r in range(len(F)):
        if r == 2 or r == KEYRING or R[r] <= 0:
            continue
        out.append((r, np.array([F[r], L[r], U[r]]), R[r]))
    out.append(('cig pocket', np.array([const(cig, 'POCKET_F'), const(cig, 'POCKET_L'), const(cig, 'POCKET_U')]),
                const(cig, 'POCKET_R')))
    return out


def label(r):
    return NAMES[r] if isinstance(r, int) else r


def grid(step=0.005):
    f = np.arange(-0.20, 0.45, step)
    l = np.arange(-0.45, 0.50, step)
    u = np.arange(-1.05, -0.20, step)
    P = np.stack(np.meshgrid(f, l, u, indexing='ij'), -1).reshape(-1, 3)
    return P, step ** 3


def winners(P, pl, pouch_c=None, pouch_r=None, reach=0.0, band=0.0):
    """index into pl of the winner of each point, -1 none (the hover loop, all ranks equal)"""
    best = np.full(len(P), 1e9)
    win = np.full(len(P), -1)
    for k, (r, c, rad) in enumerate(pl):
        if r == POUCH and pouch_c is not None:
            c, rad = pouch_c, pouch_r
        d = np.linalg.norm(P - c, axis=1)
        if r == POUCH and reach > 0:
            # the assist: the centre moved toward the hand by s = reach * ease, ease 1 inside the radius, falling to 0 at
            # radius + band; never past the hand (s <= d / 2) -- the hand's distance to the moved centre is d - s
            ease = np.clip((rad + band - d) / max(band, 1e-6), 0, 1)
            s = np.minimum(reach * ease, d * 0.5)
            d = d - s
        inside = d <= rad
        take = inside & (d < best)
        best[take] = d[take]
        win[take] = k
    return win


def report(pl, P, dv, pouch_c=None, pouch_r=None, reach=0.0, band=0.0, quiet=False):
    win = winners(P, pl, pouch_c, pouch_r, reach, band)
    vol = {}
    for k, (r, c, rad) in enumerate(pl):
        vol[r] = (win == k).sum() * dv
    return vol


def clearances(pl, c0, r0):
    out = []
    for r, c, rad in pl:
        if r == POUCH:
            continue
        gap = np.linalg.norm(c - c0) - rad - r0
        out.append((gap, label(r)))
    return sorted(out)


def main():
    src = open(RIG).read()
    cig = open(CIG).read()
    pl = places(src, cig)
    P, dv = grid()
    pc = [c for r, c, rad in pl if r == POUCH][0]
    pr = [rad for r, c, rad in pl if r == POUCH][0]
    gc = [c for r, c, rad in pl if r == GREN][0]
    gr = [rad for r, c, rad in pl if r == GREN][0]
    reach = const(src, 'POUCH_REACH_M', 0.0)
    band = const(src, 'POUCH_REACH_BAND', 0.0)
    sphere = lambda r: 4 / 3 * math.pi * r ** 3 * 1e6

    print('rig.zs as committed (right-handed, standing, BodyScale 1, Reach 1), litres (1 L = 1000 cm3):')
    print('  pouch    at f %.2f l %.2f u %.2f radius %.3f: sphere %.2f L' % (pc[0], pc[1], pc[2], pr, sphere(pr) / 1000))
    print('  grenades at f %.2f l %.2f u %.2f radius %.3f: sphere %.2f L' % (gc[0], gc[1], gc[2], gr, sphere(gr) / 1000))
    vol = report(pl, P, dv)
    print('  EFFECTIVE (won by the nearest-centre rule): pouch %.2f L (%.0f%% of its sphere), grenades %.2f L (%.0f%%), ratio %.2f'
          % (vol[POUCH] * 1e3, 100 * vol[POUCH] * 1e6 / sphere(pr), vol[GREN] * 1e3, 100 * vol[GREN] * 1e6 / sphere(gr),
             vol[POUCH] / vol[GREN]))
    if reach > 0:
        v2 = report(pl, P, dv, reach=reach, band=band)
        # the farthest a hand can be from the BASE centre and still be in the pouch, straight out (no other place nearer)
        print('  with the reach assist (%.3f m, band %.3f m): pouch %.2f L (x%.2f), grenades %.2f L; reach from the base centre %.3f m'
              % (reach, band, v2[POUCH] * 1e3, v2[POUCH] / vol[POUCH], v2[GREN] * 1e3, pr + reach))
    print('  nearest neighbours (gap = centre distance - both radii; negative = the spheres overlap by that much):')
    for gap, n in clearances(pl, pc, pr)[:6]:
        print('    %-14s %+.3f m' % (n, gap))
    print('  grenade spot to pouch centre %.3f m' % np.linalg.norm(pc - gc))

    if len(sys.argv) > 1 and sys.argv[1] == 'search':
        print('\nSEARCH: pouch spots at buckle height +-0.03, no further forward than 0.22, l 0.14..0.22, radius 0.10..0.13;')
        print('kept when it overlaps no place but the off hip and the grenade spot, by no more than 0.035 each, and is clear of')
        print('the flare by 0.05+. Sorted by the effective zone over the grenades\'.')
        rows = []
        for f in np.arange(0.16, 0.225, 0.01):
            for l in np.arange(0.14, 0.225, 0.01):
                for u in np.arange(-0.65, -0.585, 0.01):
                    for rad in (0.10, 0.11, 0.12, 0.13):
                        c = np.array([f, l, u])
                        cl = dict((n, g) for g, n in clearances(pl, c, rad))
                        bad = [n for n, g in cl.items() if g < 0 and n not in ('Left hip', 'Grenades')]
                        if bad or cl['Left hip'] < -0.035 or cl['Grenades'] < -0.035 or cl['Flare'] < 0.05:
                            continue
                        rows.append((f, l, u, rad, cl['Left hip'], cl['Grenades'], cl['Left chest'], cl['Flare']))
        P2, dv2 = grid(0.01)
        out = []
        for f, l, u, rad, hip, gre, chest, fl in rows:
            v = report(pl, P2, dv2, np.array([f, l, u]), rad)
            out.append((v[POUCH] / v[GREN], f, l, u, rad, v[POUCH] * 1e3, v[GREN] * 1e3, v[0] * 1e3, hip, gre, chest, fl))
        out.sort(reverse=True)
        print('  ratio   f     l     u     rad   pouch L  gren L  offhip L  gap hip  gap gren  gap chest  gap flare')
        for o in out[:25]:
            print('  %.2f  %.2f  %.2f  %.2f  %.2f   %.2f    %.2f    %.2f     %+.3f   %+.3f    %+.3f     %+.3f' % o)


if __name__ == '__main__':
    main()
