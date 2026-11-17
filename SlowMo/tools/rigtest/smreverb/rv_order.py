#!/usr/bin/env python3
"""rv_order.py <run.log> <label> : per tic (MAP01), which write of the sound environment stands at the end of the tic
(the last 'LiveReverb activate' or 'SlowMo write' line before 'RV t<n> end'), split standing / DOWN."""
import re, sys
log, label = sys.argv[1], sys.argv[2]
tics = {}; order = []
for ln in open(log, encoding='latin-1'):
    m = re.match(r'RV t(\d+) (.*)', ln.rstrip('\n'))
    if not m: continue
    t, what = int(m.group(1)), m.group(2)
    if t not in tics: tics[t] = {'w': [], 'down': None, 'ended': False}; order.append(t)
    d = tics[t]
    if d['ended']: continue                      # the quit tic is printed twice
    b = re.match(r'begin \(DOWN (-?\d)', what)
    if b: d['down'] = int(b.group(1))
    w = re.match(r'(LiveReverb activate|SlowMo write) env (\d+)', what)
    if w: d['w'].append(('LR' if w.group(1).startswith('Live') else 'SM', int(w.group(2)), what))
    if what == 'end': d['ended'] = True
# DOWN from the SlowMo log lines' tics: DOWN t156 .. t399 (the probe's blow at t156, getting up at t400)
src = open(log, encoding='latin-1').read()
t_down = int(re.search(r'DOWN t(\d+): player 0 went DOWN', src).group(1))
t_up = int(re.search(r'DOWN t(\d+): player 0 UP', src).group(1))
res = {}
for t in order:
    d = tics[t]
    if not d['ended'] or not d['w']: continue
    phase = 'DOWN' if t_down <= t < t_up else 'standing'
    last = d['w'][-1]
    lr = [w for w in d['w'] if w[0] == 'LR']
    lr_env = lr[-1][1] if lr else None
    key = (phase, last[0], last[1], lr_env)
    res.setdefault(key, []).append(t)
print(f'== {label}: {log}')
print(f'DOWN from t{t_down} to t{t_up - 1} (up at t{t_up}); tics counted: {sum(len(v) for v in res.values())}')
for (phase, who, env, lr_env), ts in sorted(res.items()):
    rng = f't{ts[0]}..t{ts[-1]}' if len(ts) > 1 else f't{ts[0]}'
    print(f'  {phase:8s}: {len(ts):4d} tics end with {"SlowMo" if who == "SM" else "LiveReverb"}\'s write, env {env:5d} '
          f'(LiveReverb asked {lr_env}) [{rng}]')
