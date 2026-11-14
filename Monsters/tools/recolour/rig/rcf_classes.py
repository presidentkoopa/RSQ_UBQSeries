#!/usr/bin/env python3
"""TEST ONLY: the class table of the dying-body census (rcf_classes.txt): every tierable BD22 + XMVE class of the ladder
with the death types its DECORATE has (Death.<type>, its parents' included), plus two plain deaths and a gib.
    rcf_classes.py LADDER_CSV OUT.txt SRC_ROOT [SRC_ROOT ...]   (SRC_ROOTs: unpacked pk3 text, read as data only)"""
import re, os, sys, glob, csv, collections
ladder, outp = sys.argv[1:3]
roots = sys.argv[3:]
def strip(t):
    t = re.sub(r'/\*.*?\*/', lambda m: '\n'*m.group(0).count('\n'), t, flags=re.S)
    return re.sub(r'//[^\n]*', '', t)
HDR = re.compile(r'^\s*(?:actor|class)\s+"?([\w.\-]+)"?\s*(?::\s*"?([\w.\-]+)"?)?', re.I)
LABEL = re.compile(r'^\s*([\w.]+)\s*:(?!:)')
QUOTED = re.compile(r'"([\w.\-]+)"')
ACT = {}
for r in roots:
    for f in sorted(glob.glob(r + '/**/*', recursive=True)):
        if not os.path.isfile(f): continue
        try: t = strip(open(f, encoding='latin-1').read())
        except Exception: continue
        if not re.search(r'^\s*(actor|class)\s', t, re.I | re.M): continue
        lines = t.split('\n'); i = 0
        while i < len(lines):
            m = HDR.match(lines[i])
            if not m or re.match(r'^\s*actor\s+\w+\s*\(', lines[i], re.I): i += 1; continue
            j = i; depth = 0; started = False; body = []
            while j < len(lines):
                for ch in lines[j]:
                    if ch == '{': depth += 1; started = True
                    elif ch == '}': depth -= 1
                body.append(lines[j])
                if started and depth <= 0: break
                j += 1
                if not started and j - i > 3: break
            labs = collections.OrderedDict(); cur = None; ins = False
            for L in body:
                if re.search(r'\bstates\b', L, re.I): ins = True; continue
                if not ins: continue
                lm = LABEL.match(L)
                if lm: cur = lm.group(1); labs.setdefault(cur, set())
                if cur: labs[cur] |= set(x.lower() for x in QUOTED.findall(L))
            top = re.split(r'\bstates\b', '\n'.join(body), flags=re.I)[0]
            ACT[m.group(1).lower()] = dict(name=m.group(1), parent=(m.group(2) or '').lower(), labels=labs,
                monster=bool(re.search(r'^\s*monster\b|\+ismonster', top, re.I|re.M)), file=f)
            i = j + 1
def efflabels(k, d=0):
    a = ACT.get(k)
    if not a: return {}
    o = dict(efflabels(a['parent'], d+1)) if a['parent'] and d < 20 else {}
    o.update(a['labels']); return o
rows = [x for x in csv.DictReader(open(ladder)) if x['entry tier'] != 'exempt']
out = {}
for x in rows:
    L = efflabels(x['class'].lower())
    out[x['class']] = sorted(l for l in L if re.match(r'(death|xdeath|burn|ice|disintegrate|crush|raise|wound|fatal|exec|grab|headshot|leg|critical)', l, re.I))
rows_out = []
for x in rows:
    seen = {}
    for l in out.get(x['class'], []):
        if l.lower().startswith('death.'):
            t = l.split('.', 1)[1]; seen.setdefault(t.lower(), t)
    rows_out.append('%s|%s|%s' % (x['family'], x['class'], ','.join(['None', 'XDeath', 'None'] + [seen[k] for k in sorted(seen)])))
open(outp, 'w').write('\n'.join(rows_out) + '\n')
print(len(rows_out), 'classes')
