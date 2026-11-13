#!/usr/bin/env python3
"""Exact spawn odds of XMVE spawner state machines (A_Jump chains). Usage: spawner_sim.py FILE OUTNAME"""
import re, sys, json
from fractions import Fraction as F
src = open(sys.argv[1], encoding='latin-1').read()
src = re.sub(r'//[^\n]*', '', src)
blocks = re.split(r'(?im)^\s*actor\s+', src)[1:]
out = {}
for b in blocks:
    hm = re.match(r'(\w+)[^\n]*?replaces\s+(\w+)', b, re.I)
    if not hm: continue
    name, rep = hm.group(1), hm.group(2)
    st = b[b.lower().index('states'):]
    # linearise: list of (label or None, line)
    seq = []; labels = {}
    for line in st.split('\n'):
        line = line.strip()
        if not line or line in ('{', '}'): continue
        m = re.match(r'^(\w+):\s*(.*)$', line)
        if m and not re.match(r'^\w+\s+\w', line):
            if m.group(1) not in labels: labels[m.group(1)] = len(seq)   # first definition wins
            line = m.group(2).strip()
            if not line: continue
        seq.append(line)
    res = {}; cond = set()
    def run(pc, p, depth=0):
        if depth > 60 or p == 0: return
        while pc < len(seq):
            L = seq[pc]
            low = L.lower()
            if low.startswith('stop'): return
            m = re.match(r'goto\s+(\w+)', L, re.I)
            if m: pc = labels.get(m.group(1), len(seq)); continue
            m = re.search(r'A_Jump\s*\(\s*(\d+)\s*,\s*(.*)\)', L)
            if m:
                ch = min(int(m.group(1)), 256)
                tg = [t.strip().strip('"') for t in m.group(2).split(',')]
                pj = F(ch, 256)
                for t in tg:
                    run(labels.get(t, len(seq)), p * pj / len(tg), depth + 1)
                p = p * (1 - pj); pc += 1; continue
            m = re.search(r'A_JumpIf\w*\s*\(', L)
            if m: cond.add(L[:80])
            m = re.search(r'A_SpawnItemEx?\s*\(\s*"?(\w+)"?', L)
            if m: res[m.group(1)] = res.get(m.group(1), 0) + p
            pc += 1
    run(labels.get('Spawn', 0), F(1))
    out[rep] = dict(spawner=name, odds={k: float(v) for k, v in sorted(res.items(), key=lambda x: -x[1])}, conditions=sorted(cond))
json.dump(out, open('/tmp/econ3/tiering/data/' + sys.argv[2] + '.json', 'w'), indent=1)
for rep, d in out.items():
    print(f"{rep:18} {d['spawner']:24} " + ', '.join(f"{k} {v*100:.1f}%" for k, v in d['odds'].items()))
