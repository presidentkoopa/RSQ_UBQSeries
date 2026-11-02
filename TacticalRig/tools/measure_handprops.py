#!/usr/bin/env python3
"""measure_handprops.py -- where the cigarette and the Zippo are DRAWN, relative to the controller (TEST / MEASURE ONLY).

    python3 tools/measure_handprops.py [--ws 1.02]

Reads the baked hand props (models/rsqtr/rtcig_h.md3, rtzip_h.md3, rtzipfl_h.md3; tools/gen_handprops.py) and puts their
points through the engine's own hand-model transform, read from QuestZDoom 17.3's source (qzd17.3 tag 9afc750):

  r_data/models.cpp RenderHUDModel:  GetWeaponTransform -> scale 0.01 -> translate(0, 5, 30) -> scale(MODELDEF Scale)
                                     -> translate(MODELDEF Offset) -> rotate 90 about Y -> scale vr_weaponScale
  models_md3.cpp:                    an md3 vertex (x, y, z) goes in as GL (x, z, y)
  hw_vrmodes.cpp GetWeaponTransform: the OFF hand gets scale(-1, 1, 1) (auto-reverse)
  hw_openxrdevice.cpp GetHandTransform: the controller's pose, metres x vr_vunits_per_meter (so 0.01 = 1 cm)

MODELDEF (RSQTR_CigWeapon / RSQTR_ZippoWeapon): Scale -1 1 1, Offset 0 -24 -10. Worked through, an md3 point (mx, my, mz)
in cm is drawn at, in the controller's own frame (forward along the hand, left, up; cm):
  main hand:  forward = ws*mx - 6,  left =  ws*my,  up = ws*mz - 5
  off hand:   forward = ws*mx - 6,  left = -ws*my,  up = ws*mz - 5
(The axis signs were checked on the rig by drawing a marker at the computed point beside the drawn prop:
TacticalRig/docs/cig_zone_rig.png.) cig.zs RSQTR_Cig.HandPoint does the same in the game, with vr_weaponScale read live.
"""
import argparse, os, sys
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
from gen_handprops import read_md3, unit

M = os.path.join(os.path.dirname(HERE), 'models', 'rsqtr')


def cen(pts): return tuple(sum(p[k] for p in pts) / len(pts) for k in range(3))


def frame(p, ws, off):
    return (ws * p[0] - 6.0, (-1 if off else 1) * ws * p[1], ws * p[2] - 5.0)


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--ws', type=float, default=1.02); a = ap.parse_args()
    s, _ = read_md3(open(os.path.join(M, 'rtcig_h.md3'), 'rb').read())
    pts = [p for x in s for p, _ in x['frames'][0]]
    d = unit((1.0, 0.45, 0.25))                       # gen_handprops.CIG_DIR
    pr = [sum(p[k] * d[k] for k in range(3)) for p in pts]
    hi, lo = max(pr), min(pr)
    tip = cen([p for p, q in zip(pts, pr) if q > hi - 0.3])
    fil = cen([p for p, q in zip(pts, pr) if q < lo + 0.3])
    print('cigarette (rtcig_h.md3, %d verts): filter md3 (%.2f %.2f %.2f)  tip md3 (%.2f %.2f %.2f)' % (len(pts), *fil, *tip))
    print('  drawn, main hand, cm fwd/left/up: filter (%.2f %.2f %.2f)  tip (%.2f %.2f %.2f)' % (*frame(fil, a.ws, False), *frame(tip, a.ws, False)))
    s, n = read_md3(open(os.path.join(M, 'rtzipfl_h.md3'), 'rb').read())
    fl = [p for x in s for f in range(n) for p, _ in x['frames'][f]]
    c = cen(fl); top = max(p[2] for p in fl)
    print('flame (rtzipfl_h.md3, %d frames): centre md3 (%.2f %.2f %.2f), top z %.2f' % (n, *c, top))
    print('  drawn, off hand, cm fwd/left/up: centre (%.2f %.2f %.2f), top %.2f up' % (*frame(c, a.ws, True), a.ws * top - 5.0))
    s, n = read_md3(open(os.path.join(M, 'rtcig.md3'), 'rb').read())
    xs = [p[0] for x in s for p, _ in x['frames'][0]]
    print('in the mouth (rtcig.md3 at MODELDEF scale 0.3, levelled): filter %.2f, tip %.2f map units along it (%.3f / %.3f m at 34/m)'
          % (min(xs) * 0.3, max(xs) * 0.3, min(xs) * 0.3 / 34, max(xs) * 0.3 / 34))


if __name__ == '__main__':
    main()
