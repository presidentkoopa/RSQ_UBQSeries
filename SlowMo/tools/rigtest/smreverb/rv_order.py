#!/usr/bin/env python3
"""rv_order.py <run.log> <label> : per tic (MAP01), which write of the sound environment stands at the end of the tic
(the last 'LiveReverb activate' or 'SlowMo write' line before 'RV t<n> end'), split standing / DOWN and by the player's
sector. 'room here' is worked out from the log alone: the last room id (not 65535 or another effect id) LiveReverb
asked for while the player was in that sector, before this tic (or, if none, the last room it asked for anywhere)."""
import re, sys
log, label = sys.argv[1], sys.argv[2]
EFFECT = {0xFFFF, 0x1700, 0x1800, 0x1900}
tics = {}; order = []
for ln in open(log, encoding='latin-1'):
    m = re.match(r'RV t(\d+) (.*)', ln.rstrip('\n'))
    if not m: continue
    t, what = int(m.group(1)), m.group(2)
    if t not in tics: tics[t] = {'w': [], 'down': None, 'sec': -1, 'ended': False}; order.append(t)
    d = tics[t]
    if d['ended']: continue                      # the quit tic is printed twice
    b = re.match(r'begin \(DOWN (-?\d)(?:, health -?\d+, sec (\d+))?', what)
    if b: d['down'] = int(b.group(1)); d['sec'] = int(b.group(2)) if b.group(2) else -1
    w = re.match(r'(LiveReverb activate|SlowMo write) env (\d+)', what)
    if w: d['w'].append(('LR' if w.group(1).startswith('Live') else 'SM', int(w.group(2))))
    if what == 'end': d['ended'] = True
src = open(log, encoding='latin-1').read()
t_down = int(re.search(r'DOWN t(\d+): player 0 went DOWN', src).group(1))
t_up = int(re.search(r'DOWN t(\d+): player 0 UP', src).group(1))
res = {}; room = {}; last_room = None
for t in order:
    d = tics[t]
    if not d['ended'] or not d['w']: continue
    phase = 'DOWN' if t_down <= t < t_up else 'standing'
    last = d['w'][-1]
    lr = [w[1] for w in d['w'] if w[0] == 'LR']
    lr_env = lr[-1] if lr else None
    here = room.get(d['sec'], last_room)
    key = (phase, d['sec'], last[0], last[1], lr_env, here if phase == 'DOWN' else None)
    res.setdefault(key, []).append(t)
    if lr_env is not None and lr_env not in EFFECT: room[d['sec']] = lr_env; last_room = lr_env
print(f'== {label}: {log}')
print(f'DOWN from t{t_down} to t{t_up - 1} (up at t{t_up}); tics counted: {sum(len(v) for v in res.values())}')
for (phase, sec, who, env, lr_env, here), ts in sorted(res.items(), key=lambda kv: kv[1][0]):
    rng = f't{ts[0]}..t{ts[-1]}' if len(ts) > 1 else f't{ts[0]}'
    extra = f', room here {here}' if phase == 'DOWN' else ''
    s = f' sector {sec:3d}' if sec >= 0 else ''
    print(f'  {phase:8s}{s}: {len(ts):4d} tics end with {"SlowMo" if who == "SM" else "LiveReverb"}\'s write, env {env:5d} '
          f'(LiveReverb asked {lr_env}{extra}) [{rng}]')
