#!/usr/bin/env python3
"""TEST ONLY (never ships). The lasso from a whp lasso/lassoN log (whp_metric 1, rsqwp_debug 1):
  whirl     the tip's speed while whirling (sim, room units a tic): mean / min over t40..149 (the circle at full size)
  let go    the let-go line (speed thrown at, the whirl), thrown or dropped, and which way (degrees off your facing)
  out       how far out the tip got after the let-go (flat, room units from the body), t151..180: max, and at t165
  cracks    cracks after the let-go (a thrown lasso should not crack)
    python3 lasso_metrics.py LOG [LOG ...]"""
import math, re, sys
for p in sys.argv[1:]:
    M = {}; let = thr = ''; cr = []
    for l in open(p, errors='replace'):
        if l.startswith('whp_M '):
            f = l.split()
            M[int(f[1])] = (float(f[3]), float(f[4]), float(f[5]), float(f[6]))
        elif 'LASSO let go' in l: let = re.sub(r'.*let go t\d+ ', '', l.strip())
        elif 'LASSO thrown' in l: thr = re.sub(r'.*thrown -> ', '', l.strip())
        elif l.startswith('whp_CRACK'): cr.append(int(l.split()[1][1:]))
    w = [M[t][3] for t in range(40, 150) if t in M]
    out = [math.hypot(M[t][0], M[t][1]) for t in range(151, 181) if t in M]
    print('%-10s whirl %5.1f / %5.1f  | let go %s | thrown %s | out max %5.1f, t165 %5.1f | cracks after let-go %d' % (
        re.sub(r'\.log$', '', p.split('/')[-1]), sum(w) / max(1, len(w)), min(w) if w else 0, let or '-', thr or 'DROPPED',
        max(out) if out else 0, math.hypot(M[165][0], M[165][1]) if 165 in M else 0, sum(1 for t in cr if t > 150)))
