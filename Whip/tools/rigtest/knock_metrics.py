#!/usr/bin/env python3
"""TEST ONLY. Crack Knocks Enemies Back (11-03). Reads the probe's whp_V (the tracked monster, a line a tic: pos, vel,
hp) and whp_DMG lines. For each whip hit on it (hits within 5 tics merged), over the next 60 tics: the furthest it was
moved from where it stood the tic before (3D and flat), and its peak speed. In scenario 12 the monster has Speed 0, so
it does not walk; Brutal Doom's own dodges still thrust it. tools/rigtest/knock_runs.sh makes the logs.
    python3 tools/rigtest/knock_metrics.py <logs...>"""
import sys, re, math

W = 60
for f in sys.argv[1:]:
    V = {}; hits = []; ev = []; trk = '?'; errs = 0
    for l in open(f, errors='replace'):
        m = re.match(r'whp_V (\d+) pos (\S+) (\S+) (\S+) vel (\S+) (\S+) (\S+) hp (-?\d+)', l)
        if m: V[int(m[1])] = tuple(map(float, m.groups()[1:7])) + (int(m[8]),); continue
        m = re.match(r'whp_DMG t(-?\d+) (\S+) took (\d+) \((\w+)\)', l)
        if m and m[4].lower() == 'whip': hits.append(int(m[1]))
        m = re.match(r'whp_(track|summon) t?\d* ?(\S+)', l)
        if m: trk = m[2].split('@')[0]
        if re.search(r'T_WPW \d+ (CRACK hit|WRAP|YANK|LASSO let go|SMASH)', l): ev.append(l.strip()[7:110])
        if 'Script error' in l and 'voxeldef' not in l: errs += 1
    print('== %s  (tracked %s; script errors not voxeldef: %d)' % (f.split('/')[-1], trk, errs))
    for e in ev[:8]: print('     ', e)
    hs = []
    for h in sorted(set(hits)):
        if not hs or h - hs[-1] > 5: hs.append(h)
    for h in hs:
        p0 = V.get(h - 1) or V.get(h)
        if not p0: continue
        dm = dmf = sp = 0.0; tsp = h
        for t in range(h, h + W):
            p = V.get(t)
            if not p: continue
            dm = max(dm, math.dist(p[:3], p0[:3])); dmf = max(dmf, math.dist(p[:2], p0[:2]))
            s = math.hypot(*p[3:6])
            if s > sp: sp, tsp = s, t
        pe = V.get(h + W - 1) or p0
        print('   hit t%-4d hp %4d -> %4d: moved max %6.1f (flat %6.1f), %6.1f after %d tics; peak speed %5.2f at t%d'
              % (h, p0[6], pe[6], dm, dmf, math.dist(pe[:3], p0[:3]), W, sp, tsp))
