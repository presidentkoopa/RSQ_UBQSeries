#!/usr/bin/env python3
# TEST ONLY. trt_plot.py <out.png> <title> <log>... : per log, the tracking space's turn (pawn less headset yaw), the
# rig's body and ShieldSaw's shield over time, unwrapped from the first tic, one panel per log.
import re, sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
def da(a, b):
    d = (b - a) % 360.0
    return d - 360.0 if d > 180.0 else d
def load(p):
    t, cols, trk, marks = [], [], {}, []
    for line in open(p, errors='replace'):
        m = re.match(r'trk t(\d+) (\S+)', line)
        if m: trk[int(m.group(1))] = float(m.group(2)); continue
        m = re.match(r'^(TRT_\w+)$', line.strip())
        if m: marks.append((m.group(1), len(t))); continue
        m = re.match(r'trt t(\d+) a (\S+) h0 (\S+) h1 (\S+) rig (\S+) ssk (\S+) ssq (\S+)', line)
        if m:
            k = int(m.group(1)); v = [float(x) for x in m.groups()[1:]]
            t.append(k); cols.append([trk.get(k, 999.0), v[0], v[1] + 90, v[3], v[5]])
    def un(i):
        out, acc = [0.0], 0.0
        for j in range(1, len(cols)): acc += da(cols[j - 1][i], cols[j][i]); out.append(acc)
        return out
    return t, un(0), un(1), un(2), un(3), un(4), marks
out, title, logs = sys.argv[1], sys.argv[2], sys.argv[3:]
fig, axs = plt.subplots(len(logs), 1, figsize=(11, 3.2 * len(logs)), squeeze=False)
for ax, p in zip(axs[:, 0], logs):
    t, tk, pa, h0, rg, sq, marks = load(p)
    ax.plot(t, pa, color='#bbbbbb', lw=1, label='head (pawn angle)')
    ax.plot(t, h0, color='#9fc5e8', lw=1, label='main controller')
    ax.plot(t, tk, color='black', lw=2.2, label='tracking space (pawn - headset yaw)')
    if any(abs(x) > 0.01 for x in rg): ax.plot(t, rg, color='#d62728', lw=1.4, ls='--', label='TacticalRig body')
    ax.plot(t, sq, color='#2ca02c', lw=1.2, ls=':', label='ShieldSaw shield')
    ax.set_title(p.split('/')[-1], fontsize=9); ax.set_ylabel('deg'); ax.grid(alpha=0.3)
    ax.legend(fontsize=7, loc='best')
axs[-1, 0].set_xlabel('tic')
fig.suptitle(title + '  (rig only, not headset-confirmed)', fontsize=11)
fig.tight_layout(); fig.savefig(out, dpi=80)
