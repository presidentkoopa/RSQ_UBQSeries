#!/usr/bin/env python3
# TEST ONLY. room_check.py <log>: "Torso Follows Room Turns" (gen_room_script.py). Per labelled segment: how far the pawn
# (the head in the world) and the tracking space turned; the TacticalRig body ('rig') and ShieldSaw's synced body
# ('shield'): turn, most strayed, end against the head; room-follow turns in the segment, the tic the first one started
# easing and landed (seconds after the head stopped turning, i.e. its last tic moving over 0.5 deg); the longest the
# head-held count ran; each hand's reading at the segment's middle tic (from the neck m / off the look deg / from the eyes
# m / in front), and the holsters the hands were in (trr hover main/off, -1 none) over the segment.
import re, sys
def da(a, b):
    d = (b - a) % 360.0
    return d - 360.0 if d > 180.0 else d
rows, seg, marks, trk, trc, hov = [], None, [], {}, {}, {}
for line in open(sys.argv[1], errors='replace'):
    line = line.strip()
    m = re.match(r'^(TRT_[\w.]+)$', line)
    if m: seg = m.group(1); marks.append((seg, len(rows))); continue
    m = re.match(r'trk t(\d+) (\S+)', line)
    if m: trk[int(m.group(1))] = float(m.group(2)); continue
    m = re.match(r'trr t(\d+) rec \S+ gap \S+ \S+ hover (\S+) (\S+)', line)
    if m: hov[int(m.group(1))] = '%s/%s' % (m.group(2), m.group(3)); continue
    m = re.match(r'trc t(\d+) for (\S+) on (\S+) turns (\S+) main (\S+) (\S+) (\S+) (\S+) off (\S+) (\S+) (\S+) (\S+)', line)
    if m: trc[int(m.group(1))] = [float(x) for x in m.groups()[1:]]; continue
    m = re.match(r'trt t(\d+) a (\S+) h0 (\S+) h1 (\S+) rig (\S+) ssk (\S+) ssq (\S+) pitch (\S+)', line)
    if m:
        t = int(m.group(1)); rows.append([t, seg, [float(x) for x in m.groups()[1:]]])
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
    t0, t1 = rows[i0][0], rows[i1 - 1][0]
    tk = da(trk.get(t0, 0), trk.get(t1, 0))
    end = rows[i1 - 1][2]
    c0, c1 = trc.get(t0), trc.get(t1)
    nturn = int(c1[2] - c0[2]) if c0 and c1 else -1
    mx = max((trc[r[0]][0] for r in rows[i0:i1] if r[0] in trc), default=-1)
    # the head's last moving tic, the first easing tic, the landing tic
    hstop = max((rows[i][0] for i in range(i0 + 1, i1) if abs(da(rows[i - 1][2][0], rows[i][2][0])) > 0.5), default=t0)
    ease = next((r[0] for r in rows[i0:i1] if r[0] in trc and trc[r[0]][1] > 0), None)
    land = next((rows[i][0] for i in range(i0 + 1, i1) if rows[i][0] in trc and rows[i - 1][0] in trc and trc[rows[i][0]][2] > trc[rows[i - 1][0]][2]), None)
    tm = ''
    if land: tm = ' | eased from %.2fs, landed %.2fs after the head stopped' % ((ease - hstop) / 35.0, (land - hstop) / 35.0)
    hand = ''
    cm = trc.get(rows[(i0 + i1) // 2][0])
    if cm: hand = ' | mid: main %.3f %+.1f %+.3f %d off %.3f %+.1f %+.3f %d' % tuple(cm[3:11])
    hand += ' | hover %s' % ' '.join(sorted(set(hov[r[0]] for r in rows[i0:i1] if r[0] in hov)))
    print('%-28s pawn %+8.2f trk %+8.2f | rig %+8.2f (most %6.2f, ends %+7.2f vs head) | shield %+8.2f (ends %+7.2f vs head) | room turns %d, count max %d%s%s' % (
        s, pa[-1], tk, rg[-1], max(abs(x) for x in rg), da(end[0], end[3]), sq[-1], da(end[0], end[5]), nturn, mx, tm, hand))
