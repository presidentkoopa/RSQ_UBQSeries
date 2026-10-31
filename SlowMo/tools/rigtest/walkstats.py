#!/usr/bin/env python3
# TEST ONLY. Reads smprobe mode-1 logs (T_W lines) and says how a walker moved: per-tic movement,
# how many tics moved, the longest still run, and steps a second.  walkstats.py <log>...
import re, sys
for path in sys.argv[1:]:
    rows = []
    for line in open(path, errors="replace"):
        m = re.search(r"T_W t(\d+) pos \S+ \S+ moved ([\d.]+) tics (-?\d+)", line)
        if m:
            rows.append((int(m.group(1)), float(m.group(2)), int(m.group(3))))
    rows = [r for r in rows if r[0] >= 30][:160]       # settled slow motion, 160 tics
    if not rows:
        print(path, "no T_W lines"); continue
    moved = [r[1] for r in rows]
    n = len(moved); m = sum(1 for v in moved if v > 0.01)
    run = best = 0
    for v in moved:
        run = run + 1 if v <= 0.01 else 0
        best = max(best, run)
    total = sum(moved)
    print(f"{path.split('/')[-1]}: {n} tics, moved on {m} ({100*m/n:.0f}%), largest single-tic move {max(moved):.2f}, "
          f"longest still run {best} tics, distance {total:.1f} ({total/n:.2f}/tic)")
    print("   first 40:", " ".join(f"{v:.2f}" for v in moved[:40]))
