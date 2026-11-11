#!/usr/bin/env python3
"""THE FLASHLIGHT BESIDE THE FLARE, AND THE CIGARETTE POCKET'S ROOM (owner 2026-11-11 15:19: "lets move the flashlight
adjacent to the flare, you pick where ... the problem is that i cant get to the cigarettes").

    python3 tools/measure_torch_spot.py

PARSED, NOT COPIED: every place (RSQTR_Region DF / DL / DU / DR and the seated SDF / SDL / SDU) and the flashlight's offset
from the flare place (TORCH_* / STORCH_*) from zscript/rsqtr/rig.zs; the cigarette pocket (POCKET_F / L / U / R) from
zscript/rsqtr/cig.zs; the reach assist (POUCH_REACH_M) from rig.zs; RSQ FnF's flashlight clip (its old place and its grab
radius) and its flare pocket from ../FlashFlare/CVARINFO.txt. Right-handed layout (RSQTR_Rig.Settings' "toward a hand"
flips: the whip's left toward the main hand; keyring, flare and pouch toward the off hand), Reach 1. Body Scale (Measure My
Height) 0.7, 1.0 and 1.3: the rig's offsets and radii scale with it, FnF's clip radius does not.

Arithmetic on the code's own numbers only: it says whether the grab spheres overlap, not how a hand finds them. Code only,
not shown.
"""
import os, re, math

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
RIG = os.path.join(ROOT, 'zscript', 'rsqtr', 'rig.zs')
CIG = os.path.join(ROOT, 'zscript', 'rsqtr', 'cig.zs')
FNF = os.path.normpath(os.path.join(ROOT, '..', 'FlashFlare', 'CVARINFO.txt'))
NAMES = ["Left hip", "Right hip", "", "Grenades", "Left shoulder", "Right shoulder", "Left chest", "Right chest",
         "Keyring", "Left saber", "Right saber", "Whip", "Flare", "Ammo pouch"]
KEYRING, WHIP, FLARE, POUCH = 8, 11, 12, 13


def table(src, name):
    m = re.search(r'static const double %s\[\]\s*=\s*\{([^}]*)\}' % name, src)
    return [float(x) for x in m.group(1).split(',')]


def const(src, name):
    m = re.search(r'const\s+%s\s*=\s*([-0-9.]+)' % name, src)
    return float(m.group(1))


def cvar(src, name):
    m = re.search(r'\b%s\s*=\s*([-0-9.]+)' % name, src)
    return float(m.group(1))


def places(rig, seated):
    df, dl, du, dr = table(rig, 'DF'), table(rig, 'DL'), table(rig, 'DU'), table(rig, 'DR')
    if seated:
        sf, sl, su = table(rig, 'SDF'), table(rig, 'SDL'), table(rig, 'SDU')
        for r in range(len(df)):
            if r in (0, 1, 3) or r >= 8:
                df[r], dl[r], du[r] = sf[r], sl[r], su[r]
    out = {}
    for r in range(len(df)):
        if r == 2:
            continue
        l = -dl[r] if r == WHIP else dl[r]     # right-handed: the whip's "left" is toward the main hand (the body's right)
        out[r] = ((df[r], l, du[r]), dr[r])
    return out


def main():
    rig, cig, fnf = open(RIG).read(), open(CIG).read(), open(FNF).read()
    reach = const(rig, 'POUCH_REACH_M')
    cigp = ((const(cig, 'POCKET_F'), const(cig, 'POCKET_L'), const(cig, 'POCKET_U')), const(cig, 'POCKET_R'))
    rc = cvar(fnf, 'rsqff_fl_clip_r')
    old = (cvar(fnf, 'rsqff_fl_clip_f'), cvar(fnf, 'rsqff_fl_clip_l'), cvar(fnf, 'rsqff_fl_clip_u'))
    pocket = ((cvar(fnf, 'rsqff_pocket_f'), -cvar(fnf, 'rsqff_pocket_l'), cvar(fnf, 'rsqff_pocket_u')), cvar(fnf, 'rsqff_pocket_r'))
    print('RSQ FnF clip grab radius (rsqff_fl_clip_r): %.2f m' % rc)
    print('BEFORE: FnF clip at (%.2f, %.2f, %.2f), radius 0.12 (FnF frame: the real eyes; the rig hangs from the view height)' % old)
    d = math.dist(old, cigp[0])
    print('  vs the cigarette pocket (%.2f, %.2f, %.2f) r %.2f: centres %.3f, radii %.2f, clear %+.3f' % (*cigp[0], cigp[1], d, 0.12 + cigp[1], d - 0.12 - cigp[1]))
    d = math.dist(pocket[0], cigp[0])
    print('  FnF flare pocket (%.2f, %.2f, %.2f) r %.2f (off while the flare holster is live): to the old clip %.3f, to the cigarettes %.3f'
          % (*pocket[0], pocket[1], math.dist(pocket[0], old), d))
    for seated in (False, True):
        pl = places(rig, seated)
        off = tuple(const(rig, ('STORCH_' if seated else 'TORCH_') + a) for a in 'FLU')
        fl = pl[FLARE][0]
        print('\n%s: flashlight offset from the flare place (%.2f, %.2f, %.2f)' % ('SEATED (profiles 3/4)' if seated else 'STANDING', *off))
        for k in (0.7, 1.0, 1.3):
            t = tuple((a + b) * k for a, b in zip(fl, off))
            rows = []
            spots = dict((NAMES[r], (c, rad)) for r, (c, rad) in pl.items() if r != KEYRING)
            spots['Keyring (edit only)'] = pl[KEYRING]
            spots['Cigarettes'] = cigp
            for n, (c, rad) in spots.items():
                cc = tuple(x * k for x in c)
                rr = rad * k + (reach if n == 'Ammo pouch' else 0)
                dd = math.dist(t, cc)
                rows.append((dd - rr - rc, n, dd, rr))
            rows.sort()
            print('  Body Scale %.1f: AFTER at (%.3f, %.3f, %.3f)' % (k, *t))
            for c, n, dd, rr in rows[:3] + [r for r in rows[3:] if r[1] == 'Cigarettes']:
                print('    %-20s centres %.3f  radii %.3f + %.2f  clear %+.3f' % (n, dd, rr, rc, c))
    print('\nTHE CIGARETTE POCKET against every place (standing, Body Scale 1), the flashlight included:')
    pl = places(rig, False)
    t = tuple(a + b for a, b in zip(pl[FLARE][0], tuple(const(rig, 'TORCH_' + a) for a in 'FLU')))
    spots = [(NAMES[r], c, rad) for r, (c, rad) in pl.items()] + [('FnF flashlight', t, rc)]
    rows = sorted((math.dist(cigp[0], c) - rad - (reach if n == 'Ammo pouch' else 0) - cigp[1], n, math.dist(cigp[0], c)) for n, c, rad in spots)
    for c, n, dd in rows[:5]:
        print('    %-20s centres %.3f  clear %+.3f' % (n, dd, c))
    print('    (every other place further)')


if __name__ == '__main__':
    main()
