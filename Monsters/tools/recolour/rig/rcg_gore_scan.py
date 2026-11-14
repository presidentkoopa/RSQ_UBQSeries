#!/usr/bin/env python3
"""gore_scan.py LADDER_CSV FAMILIES_DIR OUT_JSON ARCHIVE...  (archives read as data via zipfile; never extracted)
Which actors RSQ Monsters' Carry colours (RS_BDTier.zs: reached from a tierable BD22/XMVE monster, not a ladder monster,
not 'own look' by OwnLookName / Blood parents / Inventory), and the sprites they draw that no family file holds yet."""
import re, os, sys, json, csv, zipfile, collections

ladder, famdir, out_json = sys.argv[1:4]
archives = sys.argv[4:]

def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', lambda m: '\n' * m.group(0).count('\n'), t, flags=re.S)
    return re.sub(r'//[^\n]*', '', t)

HDR = re.compile(r'^\s*(?:actor|class)\s+"?([\w.\-]+)"?\s*(?::\s*"?([\w.\-]+)"?)?', re.I)
STATE = re.compile(r'^\s*(?:[\w.]+\s*:\s*)*"?([A-Za-z0-9_\[\]\\#\-]{4})"?\s+"?([A-Za-z\[\]\\#^]+)"?\s+(-?\d+|random)', re.I)
LABEL = re.compile(r'^\s*([\w.]+)\s*:(?!:)')
QUOTED = re.compile(r'"([\w.\-]+)"')
CALLARG = re.compile(r'\b(?:A_\w+|DropItem|Spawn\w*)\s*\(?\s*"?([A-Za-z_][\w.\-]*)"?', re.I)
DROP = re.compile(r'^\s*dropitem\s+"?([\w.\-]+)"?', re.I | re.M)

ACT = {}
LUMPDIR = collections.defaultdict(set)
for a in archives:
    z = zipfile.ZipFile(a); tag = os.path.basename(a)
    for info in z.infolist():
        fn = info.filename.replace('\\', '/'); rel = fn.lower()
        if info.is_dir(): continue
        if rel.startswith('sprites/'):
            LUMPDIR[os.path.basename(fn)[:4].upper()].add(tag + ':' + os.path.dirname(fn)); continue
        if rel.startswith(('sounds', 'textures', 'graphics', 'music', 'models', 'voxels', 'maps', 'flats', 'acs')): continue
        if re.search(r'\.(png|lmp|wav|ogg|mp3|flac|wad|o|md3|dmd|kvx|jpg|pcx|tga|bmp)$', rel) or info.file_size > 6_000_000: continue
        t = strip_comments(z.read(info).decode('latin-1'))
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
            name = m.group(1); b = '\n'.join(body)
            labels = collections.defaultdict(set); cur = None; ins = False
            for L in body:
                if re.search(r'\bstates\b', L, re.I): ins = True; continue
                if not ins: continue
                lm = LABEL.match(L)
                if lm: cur = lm.group(1).lower()
                sm = STATE.match(L)
                if sm and cur:
                    spr = sm.group(1).upper()
                    if spr in ('####', '----', 'TNT1'): continue
                    for c in sm.group(2).upper():
                        if c not in '#^"': labels[cur].add((spr, c))
            refs = set(x.lower() for x in QUOTED.findall(b)) | set(x.lower() for x in CALLARG.findall(b)) | set(x.lower() for x in DROP.findall(b))
            top = re.split(r'\bstates\b', b, flags=re.I)[0]
            dm = re.search(r'^\s*damage\s*\(?\s*(\d+)', top, re.I | re.M)
            ACT[name.lower()] = dict(name=name, parent=(m.group(2) or '').lower(), labels=labels, refs=refs,
                                     missile=bool(re.search(r'^\s*(\+missile|projectile)\b', top, re.I | re.M)),
                                     damage=int(dm.group(1)) if dm else 0,
                                     monster=bool(re.search(r'^\s*(\+ismonster|monster)\b', top, re.I | re.M)),
                                     file=tag + ':' + fn + ':%d' % (i + 1))
            i = j + 1

def chain(k):
    out = []
    while k and len(out) < 30:
        out.append(k); a = ACT.get(k)
        if not a: break
        k = a['parent']
    return out

def eff_labels(key, depth=0):
    a = ACT.get(key)
    if not a: return {}
    o = dict(eff_labels(a['parent'], depth + 1)) if a['parent'] and depth < 20 else {}
    o.update(a['labels']); return o

def blocked(key):
    if key not in ACT: return True
    return any(b in chain(key) for b in ('weapon', 'playerpawn', 'ammo', 'health', 'armor', 'basicarmorpickup', 'powerupgiver'))

# RS_BDTier.zs OwnLookName / Words, ported
SUB = ["blood", "gore", "smearer", "smoke", "flame", "flare", "spark", "puff", "tracer", "casing", "plasma", "splash", "steam",
       "brass", "fog", "particle", "flashlight", "shrapnel", "explosion", "bullet", "mist"]
WORD = ["fire", "light", "shell", "water", "dust", "trail", "shock", "ring", "ember", "burn", "drop", "rifle", "weapon", "ammo", "clip", "mag"]
BODYW = ["guy", "gunner", "zombie", "man", "marine", "dead", "head", "gib", "death", "half", "dying", "frozen", "major", "soldier",
         "trooper", "corpse", "body", "torso", "arm", "leg", "grabbed", "throwed", "punched", "execute"]
MODS = ["champion_", "ld", "rsq", "rs_", "ssq", "ue_"]
def words(n):
    w = ''
    for i, ch in enumerate(n):
        up, lo = ch.isupper() and ch.isascii(), ch.islower() and ch.isascii()
        if not up and not lo: w += ' '; continue
        if up and i > 0:
            p = n[i - 1]; q = n[i + 1] if i + 1 < len(n) else ''
            if (p.islower() and p.isascii()) or (p.isupper() and p.isascii() and q.islower() and q.isascii()): w += ' '
        w += ch.lower()
    return w
def own_name(n):
    low = n.lower()
    if any(low.startswith(m) for m in MODS): return True
    if any(s in low for s in SUB): return True
    w = ' ' + words(n) + ' '
    if any(' ' + x in w for x in WORD): return True
    ws = w.split(); gun = any('gun' in x for x in ws); body = any(b in x for x in ws for b in BODYW)
    return gun and not body
def keeps_own(k):
    if own_name(ACT[k]['name']): return True
    c = chain(k)
    if 'inventory' in c: return True
    return any(x in ('blood', 'supergore', 'bloodmist') for x in c)

rows = [x for x in csv.DictReader(open(ladder)) if x['entry tier'] != 'exempt']
rootkeys = set(x['class'].lower() for x in rows)
famspr = {}
for f in sorted(os.listdir(famdir)):
    if not f.endswith('.txt') or f.startswith('gore'): continue
    for l in open(os.path.join(famdir, f)):
        w = l.split('#')[0].split()
        if w and w[0] == 'sprites':
            for s in w[1:]: famspr[s.upper()] = f[:-4]

carried = collections.defaultdict(set)     # actor -> roots
for x in rows:
    key = x['class'].lower(); seen = set(); stack = [key]
    while stack:
        k = stack.pop()
        if k in seen: continue
        seen.add(k)
        if k not in ACT: continue
        if k != key and k not in rootkeys: carried[k].add(x['class'])
        for r in ACT[k]['refs'] | ({ACT[k]['parent']} if ACT[k]['parent'] else set()):
            if r in seen or r not in ACT: continue
            if r in rootkeys and r != key: continue
            if blocked(r) and r != key: continue
            stack.append(r)

spr_cls = collections.defaultdict(set); spr_letters = collections.defaultdict(set); spr_roots = collections.defaultdict(set)
own_cls = collections.defaultdict(set)
for k, rts in carried.items():
    a = ACT[k]
    if a['missile'] and a['damage'] > 0: continue           # an attack: Shot(), not Carry
    own = keeps_own(k)
    for lab, ss in eff_labels(k).items():
        for spr, c in ss:
            if own: own_cls[spr].add(a['name']); continue
            spr_cls[spr].add(a['name']); spr_letters[spr].add(c); spr_roots[spr] |= rts
res = {}
for s in sorted(spr_cls):
    res[s] = dict(family=famspr.get(s, ''), folders=sorted(LUMPDIR.get(s, [])), letters=''.join(sorted(spr_letters[s])),
                  classes=sorted(spr_cls[s]), roots=len(spr_roots[s]), also_own_look_classes=sorted(own_cls.get(s, [])))
json.dump(res, open(out_json, 'w'), indent=1)
print(len(ACT), 'actors;', len(carried), 'reached;', len(res), 'carried sprites;', sum(1 for v in res.values() if not v['family']), 'not in a family')
# own-look-only sprites in gore folders (for the record)
oo = {}
for s, cl in own_cls.items():
    if s in res: continue
    oo[s] = dict(folders=sorted(LUMPDIR.get(s, [])), classes=sorted(cl))
json.dump(oo, open(out_json.replace('.json', '_ownlook.json'), 'w'), indent=1)
