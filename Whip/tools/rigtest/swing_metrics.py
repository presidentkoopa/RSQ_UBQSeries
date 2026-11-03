#!/usr/bin/env python3
"""TEST ONLY (never ships). Reads the whp probe's "whp_S" lines (scenario 11, the aimed swing) from a rig log.

    python3 swing_metrics.py LOG [--every N]

Prints each rope (latch -> let go): where it latched, its length, the speed at the bottom of each arc (the lowest
point between turns), the fastest, the release speed; then the flight after it and the landing (where, how fast,
and whether the speed is kept on the ground for the next tics). --every N also prints every N-th tic."""
import re, sys, math

R = re.compile(r'^whp_S (\d+) (\d+) pos (\S+) (\S+) (\S+) vel (\S+) (\S+) (\S+) hspd (\S+) spd (\S+) gr (\d) hook (-?\d+) '
               r'L (\S+) d (\S+) anc (\S+) (\S+) (\S+) aim (\d) ok (\d) why (.*) end (\S+) (\S+) (\S+) whip (\d) cp (\S+)')


def parse(path):
    rows = []
    for l in open(path, errors='replace'):
        m = R.match(l)
        if not m: continue
        g = m.groups()
        rows.append(dict(t=int(g[0]), pos=tuple(map(float, g[2:5])), vel=tuple(map(float, g[5:8])), h=float(g[8]), s=float(g[9]),
                         gr=int(g[10]), hook=int(g[11]), L=float(g[12]), d=float(g[13]), anc=tuple(map(float, g[14:17])),
                         aim=int(g[17]), ok=int(g[18]), why=g[19], end=tuple(map(float, g[20:23])), whip=int(g[23])))
    return rows


def main():
    path = sys.argv[1]
    every = int(sys.argv[sys.argv.index('--every') + 1]) if '--every' in sys.argv else 0
    rows = parse(path)
    if not rows: print('no whp_S rows'); return
    if every:
        for r in rows:
            if r['t'] % every == 0:
                print('t%3d pos(%6.0f %5.0f %5.0f) v(%6.1f %5.1f %6.1f) flat %5.1f all %5.1f %s hook %2d L %5.0f aim %d ok %d %s' % (
                    r['t'], *r['pos'], *r['vel'], r['h'], r['s'], 'GROUND' if r['gr'] else 'air   ', r['hook'], r['L'], r['aim'], r['ok'], r['why']))
    # ropes: runs of hook phase 1 (PH_LATCH)
    i = 0; n = len(rows); k = 0
    while i < n:
        if rows[i]['hook'] != 1: i += 1; continue
        j = i
        while j < n and rows[j]['hook'] == 1: j += 1
        seg = rows[i:j]; k += 1
        a = seg[0]
        print('ROPE %d: latched t%d at anchor (%.0f %.0f %.0f), rope %.0f, player (%.0f %.0f %.0f) %s' % (
            k, a['t'], *a['anc'], a['L'], *a['pos'], 'on the ground' if a['gr'] else 'in the air'))
        # arc bottoms: local minima of z while in the air
        zs = [r['pos'][2] for r in seg]
        for q in range(1, len(seg) - 1):
            if zs[q] <= zs[q - 1] and zs[q] < zs[q + 1] and not seg[q]['gr']:
                print('   bottom t%d z %.0f speed %.1f (flat %.1f)' % (seg[q]['t'], zs[q], seg[q]['s'], seg[q]['h']))
        top = max(seg, key=lambda r: r['s'])
        print('   fastest t%d %.1f (flat %.1f); held %d tics' % (top['t'], top['s'], top['h'], len(seg)))
        if j < n:
            rel = rows[j]
            print('   let go t%d at (%.0f %.0f %.0f) speed %.1f (flat %.1f, up %.1f)' % (rel['t'], *rel['pos'], rel['s'], rel['h'], rel['vel'][2]))
            # flight until ground or the next rope
            q = j
            while q < n and not rows[q]['gr'] and rows[q]['hook'] != 1: q += 1
            if q < n and rows[q]['gr']:
                ld = rows[q]
                dist = math.hypot(ld['pos'][0] - rel['pos'][0], ld['pos'][1] - rel['pos'][1])
                after = [r['h'] for r in rows[q:q + 8]]
                print('   LANDED t%d at (%.0f %.0f %.0f), %d tics in the air, %.0f flat from the let-go, flat speed on landing %.1f, next tics %s' % (
                    ld['t'], *ld['pos'], ld['t'] - rel['t'], dist, ld['h'], ' '.join('%.1f' % x for x in after)))
            elif q < n:
                print('   caught by the next rope at t%d, %d tics after the let-go, at (%.0f %.0f %.0f) speed %.1f' % (
                    rows[q]['t'], rows[q]['t'] - rel['t'], *rows[q]['pos'], rows[q]['s']))
        i = j
    last = rows[-1]
    print('END t%d at (%.0f %.0f %.0f) %s' % (last['t'], *last['pos'], 'on the ground' if last['gr'] else 'in the air'))


if __name__ == '__main__':
    main()
