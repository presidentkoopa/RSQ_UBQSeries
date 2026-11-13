#!/usr/bin/env python3
"""Rough attack-damage estimate for DECORATE monsters (BD22 + live XMVE).
Per monster: the largest single attack state's summed mean damage ('volley').
Doom 'Damage N' = N*4.5 mean; A_CustomBulletAttack dmg x2 mean unless NORANDOM; A_Explode in projectile death counted at half.
ESTIMATE ONLY (+-50%). Usage: dec_damage.py OUT FILES/DIRS..."""
import re, os, sys, glob, json
out = sys.argv[1]; roots = sys.argv[2:]
files = []
for r in roots:
    if os.path.isfile(r): files.append(r); continue
    files += [f for f in glob.glob(r + '/**/*', recursive=True) if os.path.isfile(f) and re.search(r'\.(dec|txt)$', f, re.I)]
hdr = re.compile(r'^\s*actor\s+"?([\w.\-]+)"?\s*(?::\s*"?([\w.\-]+)"?)?', re.I)
acts = {}
for f in files:
    t = open(f, encoding='latin-1').read()
    t = re.sub(r'/\*.*?\*/', lambda m: '\n' * m.group(0).count('\n'), t, flags=re.S)
    t = re.sub(r'//[^\n]*', '', t)
    L = t.split('\n'); i = 0
    while i < len(L):
        m = hdr.match(L[i])
        if m:
            j = i; d = 0; s = False; body = []
            while j < len(L):
                for ch in L[j]:
                    if ch == '{': d += 1; s = True
                    elif ch == '}': d -= 1
                body.append(L[j])
                if s and d <= 0: break
                j += 1
                if not s and j - i > 3: break
            acts[m.group(1).lower()] = dict(name=m.group(1), parent=(m.group(2) or '').lower(), body='\n'.join(body), file=f, line=i + 1)
            i = j + 1; continue
        i += 1

def mean(s):
    s = s.strip().strip('"')
    m = re.match(r'^\(?\s*random\w*\s*(?:\[\w*\])?\(\s*(-?\d+)\s*,\s*(-?\d+)\s*\)\s*\)?$', s, re.I)
    if m: return (int(m.group(1)) + int(m.group(2))) / 2
    m = re.match(r'^\(?\s*(-?\d+)\s*\*\s*random\w*\(\s*(-?\d+)\s*,\s*(-?\d+)\s*\)\s*\)?$', s, re.I)
    if m: return int(m.group(1)) * (int(m.group(2)) + int(m.group(3))) / 2
    m = re.match(r'^\(?\s*random\w*\(\s*(-?\d+)\s*,\s*(-?\d+)\s*\)\s*\*\s*(-?\d+)\s*\)?$', s, re.I)
    if m: return int(m.group(3)) * (int(m.group(1)) + int(m.group(2))) / 2
    m = re.match(r'^\(?\s*(-?\d+(?:\.\d+)?)\s*\)?$', s)
    if m: return float(m.group(1))
    return None

def args_of(text, fn):
    res = []
    for m in re.finditer(r'\b' + fn + r'\s*\(', text, re.I):
        i = m.end(); d = 1; j = i
        while j < len(text) and d:
            if text[j] == '(': d += 1
            elif text[j] == ')': d -= 1
            j += 1
        a = text[i:j - 1]; parts = []; cur = ''; dd = 0
        for ch in a:
            if ch == '(': dd += 1
            if ch == ')': dd -= 1
            if ch == ',' and dd == 0: parts.append(cur.strip()); cur = ''
            else: cur += ch
        parts.append(cur.strip()); res.append(parts)
    return res

def proj(name, depth=0):
    a = acts.get(name.lower().strip('"'))
    if not a or depth > 5: return 0
    top = re.split(r'\bstates\b', a['body'], flags=re.I)[0]
    dmg = None
    m = re.search(r'^\s*damage\s+\((.*)\)\s*$', top, re.M | re.I)
    if m: dmg = mean(m.group(1))
    else:
        m = re.search(r'^\s*damage\s+(\d+)\s*$', top, re.M | re.I)
        if m: dmg = int(m.group(1)) * 4.5
    if dmg is None and a['parent']: dmg = proj(a['parent'], depth + 1)
    ex = 0
    for p in args_of(a['body'], 'A_Explode'):
        v = mean(p[0]) if p and p[0] else 128
        if v: ex = max(ex, v * 0.5)
    return (dmg or 0) + ex

def states(b):
    sm = re.search(r'\bstates\b(.*)', b, re.S | re.I)
    if not sm: return {}
    lab = {}; cur = None
    for line in sm.group(1).split('\n'):
        m = re.match(r'^\s*([A-Za-z][\w.]*)\s*:\s*$', line)
        if m: cur = m.group(1); lab.setdefault(cur, ''); continue
        if cur: lab[cur] += line + '\n'
    return lab

def volley(name, depth=0):
    a = acts.get(name.lower())
    if not a or depth > 6: return 0, ''
    best = (0, '')
    for lab, t in states(a['body']).items():
        if re.match(r'(death|xdeath|raise|spawn|pain|crush|death\.|xdeath\.|pain\.|see|idle|stand)', lab, re.I): continue
        d = 0.0
        for p in args_of(t, 'A_CustomBulletAttack'):
            try:
                n = mean(p[2]) or 1; dv = mean(p[3]) or 0
                d += n * dv * (1 if 'NORANDOM' in ','.join(p).upper() else 2)
            except Exception: pass
        for fn in ('A_CustomMissile', 'A_SpawnProjectile'):
            for p in args_of(t, fn): d += proj(p[0])
        for p in args_of(t, 'A_CustomMeleeAttack'):
            v = mean(p[0]) if p and p[0] else None
            d += v or 0
        for p in args_of(t, 'A_CustomComboAttack'):
            d += proj(p[0])
        for p in args_of(t, 'A_SpawnItemEx'):
            pd = proj(p[0])
            if pd and acts.get(p[0].lower().strip('"')) and re.search(r'^\s*projectile\s*$|\+MISSILE', acts[p[0].lower().strip('"')]['body'], re.M | re.I):
                d += pd
        if d > best[0]: best = (round(d, 1), lab)
    if best[0] == 0 and a['parent']: return volley(a['parent'], depth + 1)
    return best

res = {}
names = sys.stdin.read().split()
for n in names:
    v, lab = volley(n)
    res[n] = dict(volley=v, state=lab)
json.dump(res, open(out, 'w'), indent=1)
for n in names: print(f"{n:28} {res[n]['volley']:>8} {res[n]['state']}")
