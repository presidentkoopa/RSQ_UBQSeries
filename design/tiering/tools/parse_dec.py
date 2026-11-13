#!/usr/bin/env python3
"""Parse DECORATE actors (BD22, XMVE) for monsters: health, speed, painchance,
parent, replaces, spawner drop lists, file:line. Usage: parse_dec.py OUTNAME ROOT [ROOT...]"""
import re, os, sys, json, glob

out_name = sys.argv[1]
roots = sys.argv[2:]
OUT = "/tmp/econ3/tiering/data"

hdr = re.compile(r'^\s*actor\s+"?([\w.\-]+)"?\s*(?::\s*"?([\w.\-]+)"?)?\s*(?:replaces\s+"?([\w.\-]+)"?)?\s*(\d+)?\s*(native)?\s*(\{.*)?$', re.I)
acts = {}
order = []

def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', lambda m: '\n'*m.group(0).count('\n'), t, flags=re.S)
    return re.sub(r'//[^\n]*', '', t)

files = []
for r in roots:
    if os.path.isfile(r): files.append(r); continue
    for f in glob.glob(r + '/**/*', recursive=True):
        if os.path.isfile(f) and re.search(r'\.(dec|txt|decorate)$|/decorate[^/]*$|DECORATE', f, re.I) and os.path.getsize(f) < 4_000_000:
            files.append(f)
seen=set()
for f in [x for x in files if not (x in seen or seen.add(x))]:
    try: raw = open(f, encoding='latin-1').read()
    except Exception: continue
    t = strip_comments(raw)
    lines = t.split('\n')
    i = 0
    while i < len(lines):
        m = hdr.match(lines[i])
        if m and not re.match(r'^\s*actor\s+\w+\s*\(', lines[i], re.I):
            name = m.group(1)
            # find body: from first '{' at depth to matching '}'
            j = i; depth = 0; started = False; body = []
            while j < len(lines):
                L = lines[j]
                for ch in L:
                    if ch == '{': depth += 1; started = True
                    elif ch == '}': depth -= 1
                body.append(L)
                if started and depth <= 0: break
                j += 1
                if not started and j - i > 3: break
            b = '\n'.join(body)
            acts[name.lower()] = dict(name=name, parent=m.group(2) or '', replaces=m.group(3) or '', ednum=m.group(4) or '',
                                      file=f, line=i+1, body=b)
            order.append(name.lower())
            i = j + 1
            continue
        i += 1

def dprop(b, key):
    # only top-level property lines (before States)
    top = b.split('States')[0] if re.search(r'\bStates\b', b, re.I) else b
    top = re.split(r'\bstates\b', b, flags=re.I)[0]
    m = re.search(r'^\s*' + key + r'\s+(-?[\d.]+)\s*$', top, re.M | re.I)
    return m.group(1) if m else None

def has(b, rx):
    top = re.split(r'\bstates\b', b, flags=re.I)[0]
    return re.search(rx, top, re.I | re.M) is not None

ID = {'zombieman':(20,8,200),'shotgunguy':(30,8,170),'chaingunguy':(70,8,170),'doomimp':(60,8,200),'demon':(150,10,180),
      'spectre':(150,10,180),'cacodemon':(400,8,128),'lostsoul':(100,8,256),'painelemental':(400,8,128),'hellknight':(500,8,50),
      'baronofhell':(1000,8,50),'revenant':(300,10,100),'fatso':(600,8,80),'arachnotron':(500,12,128),'archvile':(700,15,10),
      'cyberdemon':(4000,16,20),'spidermastermind':(3000,12,40),'wolfensteinss':(50,8,170),'commanderkeen':(100,0,256),
      'bossbrain':(250,0,255),'bosseye':(1000,0,0)}

def res(name, key, idx, depth=0):
    a = acts.get(name.lower())
    if a:
        v = dprop(a['body'], key)
        if v is not None: return float(v)
        if a['parent'] and depth < 15: return res(a['parent'], key, idx, depth+1)
        return None
    if name.lower() in ID: return float(ID[name.lower()][idx])
    return None

def ismonster(name, depth=0):
    a = acts.get(name.lower())
    if not a: return name.lower() in ID
    if has(a['body'], r'^\s*monster\s*$') or has(a['body'], r'^\s*\+ISMONSTER') : return True
    if has(a['body'], r'^\s*-ISMONSTER'): return False
    return a['parent'] != '' and depth < 15 and ismonster(a['parent'], depth+1)

def countkill(name, depth=0):
    a = acts.get(name.lower())
    if not a: return name.lower() in ID
    if has(a['body'], r'^\s*-COUNTKILL'): return False
    if has(a['body'], r'^\s*monster\s*$') or has(a['body'], r'^\s*\+COUNTKILL'): return True
    return a['parent'] != '' and depth < 15 and countkill(a['parent'], depth+1)

def root(name, depth=0):
    a = acts.get(name.lower())
    if not a: return name
    if not a['parent'] or depth > 15: return a['name']
    return root(a['parent'], depth+1)

def flags(b):
    top = re.split(r'\bstates\b', b, flags=re.I)[0]
    fl = re.findall(r'^\s*([+-][\w.]+)', top, re.M)
    keep = {'+BOSS','+NOPAIN','+REFLECTIVE','+NORADIUSDMG','+NOBLOOD','+SHADOW','+FLOAT','+NOGRAVITY','+MISSILEMORE','+MISSILEEVENMORE','+DONTRIP','+BOSSDEATH','+FRIENDLY','+NOTARGET','+QUICKTORETALIATE','+LOOKALLAROUND','+NOTAUTOAIMED','+INVULNERABLE','+DONTHARMSPECIES','+FLOORCLIP','+NOINFIGHTING','+ALWAYSFAST'}
    return [f.upper() for f in fl if f.upper() in keep]

rows = []
for k in order:
    a = acts[k]
    mon = ismonster(a['name'])
    b = a['body']
    is_spawner = has(b, r'^\s*dropitem') and (a['parent'].lower() == 'randomspawner')
    if not mon and not is_spawner: continue
    hp = res(a['name'], 'Health', 0)
    sp = res(a['name'], 'Speed', 1)
    pc = res(a['name'], 'PainChance', 2)
    top = re.split(r'\bstates\b', b, flags=re.I)[0]
    drops = re.findall(r'^\s*dropitem\s+"?([\w.\-]+)"?\s*(?:,\s*(-?\d+))?\s*(?:,\s*(-?\d+))?', top, re.M | re.I)
    tag = re.search(r'^\s*tag\s+"([^"]*)"', top, re.M | re.I)
    obit = re.search(r'^\s*obituary\s+"([^"]*)"', top, re.M | re.I)
    rows.append(dict(name=a['name'], parent=a['parent'], root=root(a['name']), replaces=a['replaces'], ednum=a['ednum'],
                     file=a['file'], line=a['line'], health=hp, speed=sp, painchance=pc, monster=mon,
                     countkill=countkill(a['name']) if mon else False, spawner=is_spawner,
                     drops=[(d[0], d[1], d[2]) for d in drops] if is_spawner else [],
                     flags=flags(b), tag=tag.group(1) if tag else '', obit=obit.group(1) if obit else '',
                     renderstyle=(re.search(r'^\s*renderstyle\s+"?(\w+)', top, re.M|re.I) or [None,None])[1],
                     scale=dprop(b,'Scale')))
json.dump(rows, open(f"{OUT}/{out_name}.json", 'w'), indent=1)
print(out_name, len(acts), "actors,", sum(1 for r in rows if r['monster']), "monsters,", sum(1 for r in rows if r['spawner']), "spawners")
