# TEST ONLY. Reads the runs of batch.py: per probe shot, the angle between the laser's dot line ([RSQLS] DOT, rsqls_debug) and
# the shot that left the gun (LSP HS probe); "before": the line the dot used for an unmeasured gun before 2026-11-13 (LSP OLD).
import re, sys, math
def ang(a, b):
    la = math.sqrt(sum(x*x for x in a)); lb = math.sqrt(sum(x*x for x in b))
    c = sum(x*y for x, y in zip(a, b)) / (la * lb)
    return math.degrees(math.acos(max(-1, min(1, c))))
def perp(p, o, d):
    v = [a - b for a, b in zip(p, o)]; t = sum(x*y for x, y in zip(v, d))
    w = [x - t*y for x, y in zip(v, d)]; return math.sqrt(sum(x*x for x in w))
for name in sys.argv[1:]:
    L = open('/home/claude/rig/work/runs/%s/run.log' % name, errors='replace').read().splitlines()
    print('=== %s' % name)
    dots = {}; old = {}; gun_lines = []; res = []; real = {}
    for ln in L:
        m = re.search(r'\[RSQLS\] GUN h(\d) (.*)', ln)
        if m: gun_lines.append(ln.strip()); continue
        m = re.search(r'\[RSQLS\] DOT h(\d) t(\d+) (\S+) from ([-\d. ]+) dir ([-\d. ]+)', ln)
        if m:
            dots[(int(m.group(1)), m.group(3))] = (int(m.group(2)), [float(x) for x in m.group(4).split()], [float(x) for x in m.group(5).split()]); continue
        m = re.search(r'LSP OLD t(\d+) h(\d) (\S+) grip ([-\d. ]+) dir ([-\d. ]+)', ln)
        if m:
            old[(int(m.group(2)), m.group(3))] = ([float(x) for x in m.group(4).split()], [float(x) for x in m.group(5).split()]); continue
        m = re.search(r'LSP HS t(\d+) (probe|gun) h(\d) (\S+) from ([-\d. ]+) to ([-\d. ]+) dir ([-\d. ]+) flags', ln)
        if m:
            t, kind, h, cls = int(m.group(1)), m.group(2), int(m.group(3)), m.group(4)
            fr = [float(x) for x in m.group(5).split()]; to = [float(x) for x in m.group(6).split()]; d = [float(x) for x in m.group(7).split()]
            dk = dots.get((h, cls))
            if not dk: res.append((cls, h, kind, t, None)); continue
            dt, do, dd = dk
            after = ang(dd, d)
            ok = old.get((h, cls))
            before = ang(ok[1], d) if ok else None
            if kind == 'probe':
                res.append((cls, h, kind, t, (after, before, perp(fr, do, dd), perp(to, do, dd), t - dt)))
            else:
                real.setdefault((cls, h), []).append((d, dd))
    for g in gun_lines: print('  ' + g[:260])
    print('  %-24s %s %-5s %5s  %8s %8s  %s' % ('gun', 'h', 'kind', 't', 'after', 'before', 'shot start / hit off the dot line (map units), DOT age (tics)'))
    for cls, h, kind, t, v in res:
        if v is None: print('  %-24s %d %-5s %5d  no DOT line logged for this gun and hand' % (cls, h, kind, t)); continue
        print('  %-24s %d %-5s %5d  %7.3fd %7.3fd  start %.2f  hit %.2f  age %d' % (cls, h, kind, t, v[0], v[1] if v[1] is not None else float('nan'), v[2], v[3], v[4]))
    for (cls, h), sh in real.items():
        n = len(sh); md = [sum(s[0][i] for s in sh) / n for i in range(3)]
        print('  %-24s %d real  n=%d: mean shot direction %.3f deg off the dot line; single shots %.2f..%.2f deg (gun spread)' % (cls, h, n, ang(md, sh[-1][1]), min(ang(s[0], s[1]) for s in sh), max(ang(s[0], s[1]) for s in sh)))
