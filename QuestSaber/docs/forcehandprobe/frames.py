# TEST ONLY: frames.py <rundir> [MARK:+k ...] -> maps dumped frames to tics (frame mtime vs timestamped FHP lines);
# with marks, prints the frame nearest mark_tic + k for each
import sys, os, re, glob, bisect
d = sys.argv[1]
ts, tics, marks = [], [], {}
pend = []
for l in open(os.path.join(d, 'out'), errors='replace'):
    m = re.match(r'(\d+\.\d+) FHP t(\d+) ', l)
    if m:
        ts.append(float(m.group(1))); tics.append(int(m.group(2)))
        for p in pend: marks[p] = int(m.group(2))
        pend = []
    m2 = re.match(r'(\d+\.\d+) (MARK_\w+)', l)
    if m2: pend.append(m2.group(2))
fr = []
for f in sorted(glob.glob(os.path.join(d, '*.ppm'))):
    t = os.stat(f).st_mtime
    i = bisect.bisect_right(ts, t) - 1
    fr.append((tics[i] if i >= 0 else -1, f))
if len(sys.argv) == 2:
    print(marks); [print(os.path.basename(f), t) for t, f in fr]
for a in sys.argv[2:]:
    mk, k = a.split(':'); want = marks[mk] + int(k)
    best = min(fr, key=lambda x: abs(x[0] - want))
    print(a, want, best[0], best[1])
