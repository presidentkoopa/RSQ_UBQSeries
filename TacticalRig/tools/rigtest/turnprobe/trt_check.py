#!/usr/bin/env python3
# TEST ONLY. trt_check.py <log> [csv]: reads the turn probe's lines. For each labelled segment (TRT_*): the pawn's
# turn, the rig's body turn and ShieldSaw's (kept and synced) over the segment, and the largest per-tic gap
# between body and pawn heading change. Snap segments: each snap's pawn step and body step. Optional csv: every tic.
import re, sys
def da(a, b):
    d = (b - a) % 360.0
    return d - 360.0 if d > 180.0 else d
rows, seg, marks, trk = [], None, [], {}
for line in open(sys.argv[1], errors='replace'):
    line = line.strip()
    m = re.match(r'^(TRT_\w+)$', line)
    if m:
        seg = m.group(1); marks.append((seg, len(rows))); continue
    m = re.match(r'trk t(\d+) (\S+)', line)
    if m:
        trk[int(m.group(1))] = float(m.group(2)); continue
    m = re.match(r'trt t(\d+) a (\S+) h0 (\S+) h1 (\S+) rig (\S+) ssk (\S+) ssq (\S+) pitch (\S+)', line)
    if m:
        t = int(m.group(1)); v = [float(x) for x in m.groups()[1:]]
        rows.append([t, seg] + v + [trk.get(t, 999.0)])
if len(sys.argv) > 2 and sys.argv[2] != '-v':
    with open(sys.argv[2], 'w') as f:
        f.write('tic,segment,pawn,h0,h1,rig,ssk,ssq,pitch\n')
        for r in rows: f.write(','.join(str(x) for x in r) + '\n')
def unwrap(col, i0, i1):
    out, acc = [], 0.0
    for i in range(i0, i1):
        if i > i0: acc += da(rows[i - 1][col], rows[i][col])
        out.append(acc)
    return out
segs = [(s, i, (marks[k + 1][1] if k + 1 < len(marks) else len(rows))) for k, (s, i) in enumerate(marks)]
for s, i0, i1 in segs:
    if s in ('TRT_END',) or i1 - i0 < 2: continue
    i0 = max(i0 - 1, 0)
    pa, rg, sk, sq, tk = (unwrap(c, i0, i1) for c in (2, 5, 6, 7, 9))
    extra = ''
    h0 = unwrap(3, i0, i1); h1 = unwrap(4, i0, i1)
    hm = [(x + y) / 2 for x, y in zip(h0, h1)]
    ex = max(abs(x) for x in rg); exs = max(abs(x) for x in sq)
    gap = max(abs(p - r) for p, r in zip(pa, rg)); gaps = max(abs(p - r) for p, r in zip(pa, sq))
    # tics from the pawn's last move until the rig's body is within 1 degree of the pawn's total
    last = max([k for k in range(1, len(pa)) if abs(pa[k] - pa[k - 1]) > 0.001] or [0])
    settle = next((k - last for k in range(last, len(rg)) if abs(rg[k] - pa[-1]) < 1.0), -1)
    settles = next((k - last for k in range(last, len(sq)) if abs(sq[k] - pa[-1]) < 1.0), -1)
    gh = max(abs(x - r) for x, r in zip(hm, rg))
    lasth = max([k for k in range(1, len(hm)) if abs(hm[k] - hm[k - 1]) > 0.001] or [0])
    settleh = next((k - lasth for k in range(lasth, len(rg)) if abs(rg[k] - hm[-1]) < 1.5), -1)
    if 'SNAP' in s:
        # the snap itself: the pawn's one big step, and the body's turn over that tic and the 5 after (the controllers
        # arrive up to 2 tics late; the synced shield a tic after the keeper)
        js = [k for k in range(1, len(pa)) if abs(pa[k] - pa[k - 1]) > 20]
        if js:
            j = js[0]; e = min(j + 6, len(pa) - 1)
            extra = '  | snap: pawn step %+6.2f at +%d, rig over it %+6.2f, shield over it %+6.2f' % (pa[j] - pa[j - 1], j, rg[e] - rg[j - 1], sq[min(e + 1, len(sq) - 1)] - sq[j - 1])
        else:
            extra = '  | snap: (no snap reached the pawn)'
    if 'ROOM' in s:
        # a real turn in the room: how far the body trails the hands (their mean heading), as time at the hands' own
        # pace, and how long after the hands stop it is within 1.5 degrees of them
        lagd = [abs(x - r) for x, r in zip(hm, rg)]
        sp = [abs(hm[k] - hm[k - 1]) for k in range(1, len(hm))]
        pace = (sum(x for x in sp if x > 0.5) / max(1, len([x for x in sp if x > 0.5]))) if sp else 0
        ss = next((k - lasth for k in range(lasth, len(sq)) if abs(sq[k] - hm[-1]) < 1.5), -1)
        extra = '  | room: rig trails hands at most %.1f deg (%.2f s at their %.1f deg/tic), within 1.5 deg %s after they stop; shield %s' % (max(lagd), max(lagd) / pace / 35.0 if pace else 0, pace, ('%.2f s' % (settleh / 35.0)) if settleh >= 0 else 'not in segment', ('%.2f s' % (ss / 35.0)) if ss >= 0 else 'not in segment')
    print('%-20s tracking %8.2f  rig %8.2f (rig-tracking %+6.2f)  shield %8.2f (shield-tracking %+6.2f, shield-rig %+6.2f)%s' % (s, tk[-1], rg[-1], rg[-1] - tk[-1], sq[-1], sq[-1] - tk[-1], sq[-1] - rg[-1], extra))
    if '-v' not in sys.argv: continue
    print('%-22s tics %3d  pawn %8.2f  hand0 %8.2f  rig %8.2f  ssqKeep %8.2f  ssqSynced %8.2f | rig: most %6.2f, most behind pawn %6.2f, settled +%d tics | ssq: most %6.2f, behind %6.2f, settled +%d | rig vs hands: most apart %6.2f, within 1.5 deg +%d tics after they stop' % (s, i1 - i0, pa[-1], h0[-1], rg[-1], sk[-1], sq[-1], ex, gap, settle, exs, gaps, settles, gh, settleh))
