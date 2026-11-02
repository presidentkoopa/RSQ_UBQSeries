#!/usr/bin/env python3
"""TEST ONLY (never ships). Reads the whp probe's "whp_M" lines (whp_metric 1) from rig logs and prints the
physics metrics the 11-02 rebuild is judged by:

  lerr     worst link-length error, % of a link (mean / max); stretch = the same counting only links too LONG
           (a link too short is the thong folding where it piles up against a wall)
  peaks    the sim's tip-speed peaks (room units a tic) over 10, with their tic: a clean crack is ONE sharp peak
  sharp    per swing window: how many local tip-speed maxima reach half of that window's top (1 = one clean peak)
  flips/s  the tip's direction reversals a second (body frame, per tic, both tics moving > 0.5): the "erratic" number
  jerk     the tip's jerk, room units / tic^3 (third difference of its body-frame path): RMS and max
  KE/vmax  the chain's kinetic energy (unit masses, body frame) and the fastest node: a blow-up shows here
  mend     tics with a link mended out of a wall; strt = Straightens; wall = tics a link segment is through a wall
  lag      the simulated handle tip behind the raw one, tics (best fit 0..4, 0.05 steps): the input filter's latency
  ms       the whip handler's cost a tic (all whips): mean / max

    python3 whp_metrics.py LOG [LOG ...]        one row each
    python3 whp_metrics.py --swings 60,160 LOG   also the per-swing windows (start tics, 60 tics each)
    python3 whp_metrics.py --from 30 LOG         only from tic 30 (the whip is drawn at t0 and falls for ~15 tics)
"""
import math, re, sys


def parse(path):
    rows = []
    for l in open(path, errors='replace'):
        if not l.startswith('whp_M '):
            continue
        f = l.split()
        try:
            v = [float(x) for x in f[1:]]
        except ValueError:
            continue
        if len(v) < 21:
            continue
        rows.append(dict(t=int(v[0]), mt=int(v[1]), tip=(v[2], v[3], v[4]), tsp=v[5], hsp=v[6], lerr=v[7], ke=v[8],
                         vmax=v[9], stuck=int(v[10]), strt=int(v[11]), cracks=int(v[12]), raw=(v[13], v[14], v[15]),
                         anc=(v[16], v[17], v[18]), wall=int(v[19]), ms=v[20], lstr=v[21] if len(v) > 21 else float('nan')))
    return rows


def sub(a, b): return (a[0] - b[0], a[1] - b[1], a[2] - b[2])
def ln(a): return math.sqrt(a[0] ** 2 + a[1] ** 2 + a[2] ** 2)
def dot(a, b): return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def lag(rows):
    raw = [r['raw'] for r in rows]; anc = [r['anc'] for r in rows]
    if len(raw) < 20:
        return float('nan')
    # only where the hand moves: a still hand fits any lag
    best, bl = None, 0.0
    for k in range(0, 81):
        L = k * 0.05; n = int(math.floor(L)); fr = L - n
        e = 0.0; c = 0
        for t in range(n + 1, len(raw)):
            a, b = raw[t - n], raw[t - n - 1]
            r = tuple(a[j] * (1 - fr) + b[j] * fr for j in range(3))
            if ln(sub(raw[t], raw[t - 1])) < 0.3:
                continue
            e += ln(sub(anc[t], r)) ** 2; c += 1
        if c and (best is None or e / c < best):
            best, bl = e / c, L
    return bl if best is not None else float('nan')


def metrics(rows, swings=(), t0=2):
    rows = [r for r in rows if r['t'] >= t0]
    if not rows:
        return None
    N = len(rows)
    tip = [r['tip'] for r in rows]
    v = [sub(tip[k], tip[k - 1]) for k in range(1, N)]
    flips = sum(1 for k in range(1, len(v)) if ln(v[k]) > 0.5 and ln(v[k - 1]) > 0.5 and dot(v[k], v[k - 1]) < 0)
    j = [ln(sub(sub(tip[k], tip[k - 3]), tuple(3 * x for x in sub(tip[k - 1], tip[k - 2])))) for k in range(3, N)]
    tsp = [r['tsp'] for r in rows]
    peaks = [(rows[k]['t'], tsp[k]) for k in range(1, N - 1) if tsp[k] > 10 and tsp[k] >= tsp[k - 1] and tsp[k] > tsp[k + 1]]
    strt = len({r['strt'] for r in rows if r['strt'] >= rows[0]['mt']})
    out = dict(
        N=N,
        lerr_mean=100 * sum(r['lerr'] for r in rows) / N, lerr_max=100 * max(r['lerr'] for r in rows),
        str_mean=100 * sum(max(0, r['lstr']) for r in rows) / N, str_max=100 * max(r['lstr'] for r in rows),
        flips_s=flips / (N / 35.0), jerk_rms=math.sqrt(sum(x * x for x in j) / max(1, len(j))), jerk_max=max(j) if j else 0,
        ke_max=max(r['ke'] for r in rows), vmax=max(r['vmax'] for r in rows),
        mend=sum(1 for r in rows if r['stuck'] > 0), strt=strt, wall=sum(1 for r in rows if r['wall'] > 0),
        cracks=rows[-1]['cracks'] - rows[0]['cracks'], peaks=peaks, lag=lag(rows),
        ms_mean=sum(r['ms'] for r in rows) / N, ms_max=max(r['ms'] for r in rows),
        tsp_max=max(tsp))
    sw = []
    for s0 in swings:
        w = [r for r in rows if s0 <= r['t'] < s0 + 60]
        if len(w) < 5:
            continue
        ts = [r['tsp'] for r in w]
        top = max(ts)
        lm = sum(1 for k in range(1, len(ts) - 1) if ts[k] >= 0.5 * top and ts[k] >= ts[k - 1] and ts[k] > ts[k + 1])
        sw.append((s0, top, lm))
    out['swings'] = sw
    return out


def row(name, m):
    pk = ' '.join('t%d:%.0f' % p for p in sorted(m['peaks'], key=lambda p: -p[1])[:4])
    s = ('%-14s lerr %5.2f/%6.2f%%  stretch %5.2f/%6.2f%%  flips/s %5.2f  jerk %6.2f/%7.2f  KE %8.1f vmax %6.1f  tipmax %6.1f  cracks %d  '
         'mend %3d strt %d wall %3d  lag %.2f  ms %.3f/%.3f  peaks %s') % (
        name, m['lerr_mean'], m['lerr_max'], m['str_mean'], m['str_max'], m['flips_s'], m['jerk_rms'], m['jerk_max'], m['ke_max'], m['vmax'], m['tsp_max'],
        m['cracks'], m['mend'], m['strt'], m['wall'], m['lag'], m['ms_mean'], m['ms_max'], pk)
    if m['swings']:
        s += '  swings ' + ' '.join('[t%d top %.0f, %d peak(s)]' % x for x in m['swings'])
    return s


if __name__ == '__main__':
    a = sys.argv[1:]
    swings = (); t0 = 2
    while a and a[0].startswith('--'):
        if a[0] == '--swings': swings = tuple(int(x) for x in a[1].split(','))
        elif a[0] == '--from': t0 = int(a[1])
        a = a[2:]
    for p in a:
        m = metrics(parse(p), swings, t0)
        name = re.sub(r'\.log$', '', p.split('/')[-1])
        print(row(name, m) if m else '%-14s no whp_M lines' % name)
