#!/usr/bin/env python3
"""THE SEATED DEFAULTS (Report rec 8, 11-08): where the hip holsters and the low belt spots sit by default in the two
seated holster profiles (Seated A / Seated B, rsqtr_profile_active 3 and 4), and the overlap check against today's
standing layout.

    python3 tools/seated_layout.py     # check the tables committed in zscript/rsqtr/rig.zs, print the report

The seated table was placed by hand, to the cm, and kept only once this check passed (exit 0 = PASS).

PARSED, NOT COPIED: the standing table (RSQTR_Region DF / DL / DU / DR) and the seated table (SDF / SDL / SDU) are read
from rig.zs, the cigarette pocket (POCKET_F / L / U / R) from cig.zs. Right-handed layout (the "toward a hand" flips of
RSQTR_Rig.Settings applied: the whip's left toward the main hand, the keyring's, flare's and pouch's toward the off hand).

THE BODY FRAME WHEN SEATED (body.zs At / SeatedHead): offsets are metres from your SEATED EYES (the headset's height,
the highest it has been lately), forward / left / up in the torso's frame, times BodyScale (your standing eye height
over REF_EYE 1.62; 1.0 never measured). At level pitch the neck shift is 0. So a seated landmark at REF_EYE scale is
the seated eye height minus the landmark's height above the floor, scaled by 1.62 / the standing eye height of the
same body.

THE SEATED BODY (the code has none): 50th-percentile US adults from ANSUR II (Gordon et al. 2014, 2012 Anthropometric
Survey of U.S. Army Personnel), as tabled by the Ergonomics Center of North Carolina, "Anthropometric Data for U.S.
Adults" (2017, https://www.ergocenter.ncsu.edu/wp-content/uploads/sites/18/2017/09/Anthropometric-Summary-Data-Tables.pdf),
inches. Each body is scaled to REF_EYE by its own standing eye height, as BodyScale scales the rig.
"""
import os, re, sys, math
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
RIG = os.path.join(ROOT, 'zscript', 'rsqtr', 'rig.zs')
CIG = os.path.join(ROOT, 'zscript', 'rsqtr', 'cig.zs')
REF_EYE = 1.62

# inches, 50th percentile (source above)
ANSUR = {
    'men':   dict(eye_stand=64.57, eye_sit=31.65, elbow_rest=9.69, thigh_clear=7.09, hip_breadth=13.54),
    'women': dict(eye_stand=59.72, eye_sit=29.45, elbow_rest=9.17, thigh_clear=6.57, hip_breadth=13.90),
}

NAMES = ["Left hip", "Right hip", "", "Grenades", "Left shoulder", "Right shoulder", "Left chest", "Right chest",
         "Keyring", "Left saber", "Right saber", "Whip", "Flare", "Ammo pouch"]
HIPS = (0, 1)
LOW = (3, 8, 9, 10, 11, 12, 13)          # the low belt / item spots the seated table moves
MOVED = HIPS + LOW
KEYRING = 8


def landmarks():
    """seated landmarks in the body frame (metres from the seated eyes at REF_EYE scale), per body"""
    out = {}
    for who, a in ANSUR.items():
        s = REF_EYE / a['eye_stand']
        out[who] = dict(
            seat=-a['eye_sit'] * s,                                  # the seat surface
            lap=-(a['eye_sit'] - a['thigh_clear']) * s,              # the top of the thighs (thigh clearance over the seat)
            armrest=-(a['eye_sit'] - a['elbow_rest']) * s,           # an armrest's top (elbow rest height over the seat)
            hip_half=a['hip_breadth'] / 2 * s,                       # the hips' outer side (half the seated hip breadth)
        )
    return out


def parse_arrays(path, names):
    src = open(path).read()
    vals = {}
    for n in names:
        m = re.search(r'static const double %s\[\]\s*=\s*\{([^}]*)\}' % n, src)
        if not m:
            return None
        vals[n] = [float(x) for x in m.group(1).replace(' ', '').split(',') if x != '']
    return vals


def pocket():
    src = open(CIG).read()
    g = lambda k: float(re.search(r'const %s\s*=\s*(-?[0-9.]+)' % k, src).group(1))
    return (g('POCKET_F'), g('POCKET_L'), g('POCKET_U'), g('POCKET_R'))


def flips(c):
    """RSQTR_Rig.Settings, right-handed (LeftHanded and LayoutLeft false): the whip's left is toward the main hand"""
    c = [list(x) for x in c]
    c[11][1] = -c[11][1]
    return c


def table(arr, f, l, u, r):
    return flips([(arr[f][i], arr[l][i], arr[u][i], arr[r][i]) for i in range(len(NAMES))])


def spheres(c, with_keyring):
    """(name, centre, radius) of every live place: index 2 is retired; the keyring is no holster outside edit mode
    (WorldTick skips it), so it is checked on its own"""
    out = []
    for i, (f, l, u, r) in enumerate(c):
        if NAMES[i] == '' or (i == KEYRING and not with_keyring):
            continue
        out.append((NAMES[i], np.array([f, l, u]), r))
    pf, pl, pu, pr = pocket()
    out.append(('Cigarette pocket', np.array([pf, pl, pu]), pr))
    return out


def pairs(sph):
    res = []
    for i in range(len(sph)):
        for j in range(i + 1, len(sph)):
            d = np.linalg.norm(sph[i][1] - sph[j][1])
            pen = sph[i][2] + sph[j][2] - d
            if pen > 0:
                res.append((pen, sph[i][0], sph[j][0], d))
    res.sort(reverse=True)
    return res


def ownership(sph, grid=0.01, mc=200000, seed=7):
    """the nearest-centre rule (WorldTick, a hand inside two places takes the nearest centre when neither is preferred):
    the share of each sphere a hand would get. A 1 cm grid and a Monte Carlo of mc points per sphere."""
    C = np.array([s[1] for s in sph]); R = np.array([s[2] for s in sph])
    rng = np.random.default_rng(seed)
    res = {}
    for k, (n, c, r) in enumerate(sph):
        # 1 cm grid
        ax = np.arange(-r, r + 1e-9, grid)
        g = np.stack(np.meshgrid(ax, ax, ax, indexing='ij'), -1).reshape(-1, 3)
        g = g[np.linalg.norm(g, axis=1) <= r] + c
        # Monte Carlo
        v = rng.normal(size=(mc, 3)); v /= np.linalg.norm(v, axis=1)[:, None]
        p = c + v * (r * rng.random(mc) ** (1 / 3))[:, None]
        sh = []
        for pts in (g, p):
            d = np.linalg.norm(pts[:, None, :] - C[None, :, :], axis=2)
            inside = d <= R[None, :]
            d = np.where(inside, d, np.inf)
            sh.append(float(np.mean(np.argmin(d, axis=1) == k)))
        res[n] = sh
    return res


def report(label, c, lm=None):
    print('== %s ==' % label)
    for i in MOVED:
        f, l, u, r = c[i]
        line = '  %-11s f %+.2f  l %+.2f  u %+.2f  r %.2f' % (NAMES[i], f, l, u, r)
        if lm:
            line += '   above the seat: ' + ', '.join('%s %.3f' % (w, u - lm[w]['seat']) for w in lm)
        print(line)
    hov = spheres(c, False)
    pp = pairs(hov)
    print('  overlaps among the places a hand can take (r1 + r2 - distance, m):')
    for pen, a, b, d in pp:
        print('    %.3f  %s / %s (centres %.3f apart)' % (pen, a, b, d))
    own = ownership(hov)
    print('  share of each sphere a hand gets by the nearest-centre rule (1 cm grid, Monte Carlo):')
    for n, (sg, sm) in own.items():
        print('    %-17s %.3f  %.3f' % (n, sg, sm))
    kp = [x for x in pairs(spheres(c, True)) if 'Keyring' in (x[1], x[2])]
    print('  the keyring (no holster outside Move Holsters by Hand) against the rest:')
    for pen, a, b, d in kp:
        print('    %.3f  %s / %s' % (pen, a, b))
    return pp, own, kp


def check_seated(c, lm):
    """the brief's rules: hips 0.10-0.15 m over the seat and forward of the hip joint (f > 0, the standing hips' own f,
    under the eyes); low spots no lower than the hips; every moved centre inboard of the hips' outer side (clear of an
    armrest, which can be no nearer the middle than the hips are wide) and under the armrest's top or not, reported"""
    ok = True
    hu = min(c[0][2], c[1][2])
    for w, m in lm.items():
        for i in HIPS:
            up = c[i][2] - m['seat']
            good = 0.10 <= up <= 0.15 and c[i][0] > 0
            ok &= good
            print('  %-5s %-9s %.3f over the seat, %.2f forward of the hip joint: %s' % (w, NAMES[i], up, c[i][0], 'ok' if good else 'NO'))
    for i in LOW:
        good = c[i][2] >= hu - 1e-9
        ok &= good
        print('  %-11s u %+.2f, the hips %+.2f: %s' % (NAMES[i], c[i][2], hu, 'no lower than the hips' if good else 'LOWER THAN THE HIPS'))
    half = min(m['hip_half'] for m in lm.values())
    for i in MOVED:
        good = abs(c[i][1]) < half
        ok &= good
        print('  %-11s |l| %.2f, the hips\' outer side %.3f: %s' % (NAMES[i], abs(c[i][1]), half, 'inboard (over the lap / belly)' if good else 'AT THE ARMREST'))
    return ok


def main():
    lm = landmarks()
    print('THE SEATED BODY at REF_EYE %.2f (metres from the seated eyes, ANSUR II 50th percentile, scaled by standing eye):' % REF_EYE)
    for w, m in lm.items():
        print('  %-5s seat %+.3f  lap top %+.3f  armrest top %+.3f  hips\' outer side %.3f' % (w, m['seat'], m['lap'], m['armrest'], m['hip_half']))
    std_arr = parse_arrays(RIG, ['DF', 'DL', 'DU', 'DR'])
    std = table(std_arr, 'DF', 'DL', 'DU', 'DR')
    sea_arr = parse_arrays(RIG, ['SDF', 'SDL', 'SDU'])
    if not sea_arr:
        print('no seated table (SDF / SDL / SDU) in rig.zs'); return 1
    sea_arr['DR'] = std_arr['DR']
    sea = table(sea_arr, 'SDF', 'SDL', 'SDU', 'DR')
    sp, so, sk = report('STANDING (today, DF/DL/DU/DR)', std)
    tp, to, tk = report('SEATED (SDF/SDL/SDU, radii DR)', sea, lm)
    print('== the seated rules ==')
    ok = check_seated(sea, lm)
    # NO NEW OVERLAP WORSE THAN TODAY'S STANDING LAYOUT: the seated worst pair no deeper than the standing worst pair,
    # and the smallest share of any moved place no smaller than the smallest standing share
    sw = sp[0][0] if sp else 0.0
    tw = tp[0][0] if tp else 0.0
    smin = min(min(v) for n, v in so.items() if n in [NAMES[i] for i in MOVED])
    tmin = min(min(v) for n, v in to.items() if n in [NAMES[i] for i in MOVED])
    kw_s = sk[0][0] if sk else 0.0
    kw_t = tk[0][0] if tk else 0.0
    print('== against standing ==')
    print('  worst overlap: standing %.3f (%s / %s), seated %.3f (%s / %s): %s' % (sw, sp[0][1], sp[0][2], tw, tp[0][1] if tp else '-', tp[0][2] if tp else '-', 'ok' if tw <= sw + 1e-9 else 'WORSE'))
    print('  smallest share of a moved place: standing %.3f, seated %.3f: %s' % (smin, tmin, 'ok' if tmin >= smin - 1e-9 else 'WORSE'))
    print('  keyring worst overlap: standing %.3f, seated %.3f: %s' % (kw_s, kw_t, 'ok' if kw_t <= kw_s + 1e-9 else 'WORSE'))
    ok &= tw <= sw + 1e-9 and tmin >= smin - 1e-9 and kw_t <= kw_s + 1e-9
    print('RESULT: %s' % ('PASS' if ok else 'FAIL'))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
