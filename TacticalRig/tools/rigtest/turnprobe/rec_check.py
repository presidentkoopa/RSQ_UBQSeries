#!/usr/bin/env python3
# TEST ONLY. rec_check.py <log>: the recenter tests (gen_rec_script.py). Per labelled segment: how far the pawn (the head
# in the world) and the tracking space turned, how far the TacticalRig body ('rig') and the ShieldSaw body ('shield',
# synced) turned, the most either strayed from where it started, where each ends against the head (body - pawn), and
# how many recenters fired in the segment (rig's counter, ShieldSaw's own keeper's counter).
import re, sys
def da(a, b):
    d = (b - a) % 360.0
    return d - 360.0 if d > 180.0 else d
rows, seg, marks, trk, rec = [], None, [], {}, {}
for line in open(sys.argv[1], errors='replace'):
    line = line.strip()
    m = re.match(r'^(TRT_\w+)$', line)
    if m: seg = m.group(1); marks.append((seg, len(rows))); continue
    m = re.match(r'trk t(\d+) (\S+)', line)
    if m: trk[int(m.group(1))] = float(m.group(2)); continue
    m = re.match(r'trr t(\d+) rec (\S+) gap (\S+) (\S+) hover (\S+) (\S+) .* ssrec (\S+)', line)
    if m: rec[int(m.group(1))] = m.groups()[1:]; continue
    m = re.match(r'trt t(\d+) a (\S+) h0 (\S+) h1 (\S+) rig (\S+) ssk (\S+) ssq (\S+) pitch (\S+)', line)
    if m:
        t = int(m.group(1)); v = [float(x) for x in m.groups()[1:]]
        rows.append([t, seg, v, trk.get(t, 999.0), None])
for r in rows: r[4] = rec.get(r[0])
segs = [(s, i, (marks[k + 1][1] if k + 1 < len(marks) else len(rows))) for k, (s, i) in enumerate(marks)]
def col(i0, i1, c):
    out, acc = [], 0.0
    for i in range(i0, i1):
        if i > i0: acc += da(rows[i - 1][2][c], rows[i][2][c])
        out.append(acc)
    return out
for s, i0, i1 in segs:
    if s == 'TRT_START' or i1 - i0 < 2: continue
    i0 = max(i0 - 1, 0)
    pa, rg, sq = col(i0, i1, 0), col(i0, i1, 3), col(i0, i1, 5)
    tk = da(rows[i0][3], rows[i1 - 1][3]) if rows[i0][3] != 999 and rows[i1 - 1][3] != 999 else float('nan')
    r0, r1 = rows[i0][4], rows[i1 - 1][4]
    nrec = (int(r1[0]) - int(r0[0])) if r0 and r1 and r0[0] != '-1' else 0
    nss = (int(r1[5]) - int(r0[5])) if r0 and r1 else 0
    mg = min((float(r[4][1]) + float(r[4][2])) / 2 for r in rows[i0:i1] if r[4]) if any(r[4] for r in rows[i0:i1]) else -1
    hov = sorted(set('%s/%s' % (r[4][3], r[4][4]) for r in rows[i0:i1] if r[4]))
    end = rows[i1 - 1][2]
    rigE = end[3]; ssE = end[5]
    print('%-26s pawn %+8.2f trk %+8.2f | rig %+8.2f (most %6.2f, ends %+7.2f vs head) | shield %+8.2f (most %6.2f, ends %+7.2f vs head) | recenters rig %d ss %d | closest mean gap %.3f m, hover %s' % (
        s, pa[-1], tk, rg[-1], max(abs(x) for x in rg), da(end[0], rigE) if rigE != 999 else float('nan'), sq[-1], max(abs(x) for x in sq), da(end[0], ssE), nrec, nss, mg, ' '.join(hov)))
