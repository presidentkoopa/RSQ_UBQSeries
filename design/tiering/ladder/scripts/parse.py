# Generic ZScript/DECORATE actor parser -> classes dict (pickle). Research only.
import re, os, sys, pickle

HDR = re.compile(r'^\s*(class|actor)\s+([\w\-\.]+)\s*(?::\s*([\w\-\.]+))?(.*)$', re.I)
CTL = re.compile(r'^(goto|loop|stop|wait|fail)\b\s*([\w\.:]+)?\s*(?:\+\s*(\d+))?', re.I)
FRM = re.compile(r'^("[^"]*"|[\w#\-]{4})\s+("[^"]*"|[\w\[\]\\#\^]+)\s+(-?\d+|random\s*\([^)]*\))\s*(.*)$', re.I)
KW = re.compile(r'^(bright|fast|slow|nodelay|canraise|light\s*\([^)]*\)|offset\s*\([^)]*\))\s*', re.I)

def strip_comments(txt):
    out = []; i = 0; n = len(txt); instr = False
    while i < n:
        c = txt[i]
        if instr:
            out.append(c)
            if c == '\\' and i + 1 < n: out.append(txt[i+1]); i += 2; continue
            if c == '"': instr = False
            i += 1; continue
        if c == '"': instr = True; out.append(c); i += 1; continue
        if txt.startswith('//', i):
            j = txt.find('\n', i); i = n if j < 0 else j; continue
        if txt.startswith('/*', i):
            j = txt.find('*/', i + 2); seg = txt[i:(n if j < 0 else j + 2)]
            out.append('\n' * seg.count('\n')); i = n if j < 0 else j + 2; continue
        out.append(c); i += 1
    return ''.join(out)

def parse_file(path, classes, tag):
    raw = open(path, encoding='latin-1').read().replace('\r', '')
    L = strip_comments(raw).split('\n')
    i = 0
    while i < len(L):
        m = HDR.match(L[i])
        if not m or m.group(1).lower() == 'class' and ('extend' in L[i].lower()[:12]):
            i += 1; continue
        name, parent, rest = m.group(2), m.group(3), m.group(4) or ''
        rep = re.search(r'replaces\s+([\w\-\.]+)', rest, re.I)
        # find body by brace depth
        depth = 0; started = False; j = i; body = []
        while j < len(L):
            s = L[j]
            for ch in s:
                if ch == '{': depth += 1; started = True
                elif ch == '}': depth -= 1
            body.append((j + 1, s))
            if started and depth <= 0: break
            if not started and j > i + 3: break
            j += 1
        if not started:
            i += 1; continue
        c = {'name': name, 'parent': parent, 'replaces': rep.group(1) if rep else None, 'file': path, 'line': i + 1,
             'tag': tag, 'props': {}, 'flags': {}, 'labels': {}, 'frames': [], 'uservars': {}, 'dropitems': []}
        parse_body(c, body)
        classes[name.lower()] = c
        i = j + 1

def parse_body(c, body):
    # identify states block lines
    inst = False; sdepth = 0; pending = None
    lines = body[1:] if body and HDR.match(body[0][1]) and '{' not in body[0][1] else body
    first = True
    for ln, s in body:
        t = s.strip()
        if first:
            first = False
            k = t.find('{')
            if k >= 0: t = t[k+1:].strip()
            else: continue
        if not inst:
            if re.match(r'^states\b', t, re.I):
                inst = True; sdepth = 0
                k = t.find('{')
                if k >= 0: sdepth = 1; t = t[k+1:].strip()
                else: continue
                if not t: continue
            else:
                parse_prop_line(c, ln, t); continue
        # inside states
        if sdepth == 0:
            if t.startswith('{'): sdepth = 1; t = t[1:].strip()
            if not t: continue
        if pending is not None:
            pending[1] += ' ' + t
            if pending[1].count('{') <= pending[1].count('}'):
                add_state_line(c, pending[0], pending[1]); pending = None
            continue
        # end of states?
        if t == '}' or t.startswith('}') and sdepth == 1:
            inst = False; continue
        if not t: continue
        # labels possibly followed by content
        while True:
            m = re.match(r'^([\w\.]+(?:::[\w\.]+)?)\s*:(?!:)\s*(.*)$', t)
            if m and not FRM.match(t):
                c['labels'][m.group(1).lower()] = len(c['frames'])
                c.setdefault('label_order', []).append((m.group(1), len(c['frames'])))
                t = m.group(2).strip()
                if not t: break
                continue
            break
        if not t: continue
        if t.count('{') > t.count('}'):
            pending = [ln, t]; continue
        add_state_line(c, ln, t)

def add_state_line(c, ln, t):
    t = t.rstrip(';').strip()
    m = CTL.match(t)
    if m and not FRM.match(t):
        c['frames'].append({'ctl': m.group(1).lower(), 'target': m.group(2), 'ofs': int(m.group(3) or 0), 'ln': ln})
        return
    m = FRM.match(t)
    if not m: return
    spr, letters, tics, rest = m.group(1), m.group(2).strip('"'), m.group(3), m.group(4)
    fast = False; bright = False
    while True:
        k = KW.match(rest)
        if not k: break
        w = k.group(1).lower()
        if w == 'fast': fast = True
        if w == 'bright': bright = True
        rest = rest[k.end():]
    rest = rest.strip().rstrip(';').strip()
    if tics.lower().startswith('random'):
        a = re.findall(r'-?\d+', tics); tics_v = (int(a[0]) + int(a[1])) / 2 if len(a) >= 2 else 1
    else: tics_v = int(tics)
    letters = letters.replace('\\', '')
    for k in range(max(1, len(letters))):
        c['frames'].append({'ln': ln, 'tics': tics_v, 'fast': fast, 'act': rest, 'spr': spr})

PROPKEYS = ('health','speed','fastspeed','painchance','mass','meleedamage','meleerange','minmissilechance','maxtargetrange',
            'damage','damagefunction','radius','height','reactiontime','meleethreshold','damagetype','inventory.maxamount',
            'floatspeed','gibhealth','species','tag','obituary','renderstyle','alpha','painthreshold','damagefactor')

def parse_prop_line(c, ln, t):
    t = t.strip()
    if not t or t == '}' or t.startswith('{'):
        t = t.strip('{}').strip()
        if not t: return
    # ZScript member vars
    m = re.match(r'^(?:int|double|float|bool)\s+([\w,\s]+);', t, re.I)
    if m:
        for v in m.group(1).split(','): c['uservars'][v.strip().lower()] = 0
        return
    if re.match(r'^(default|override|virtual|action|static|void|const|property|meta|states\b)', t, re.I): return
    if t.lower().startswith('var '):
        m = re.match(r'var\s+\w+\s+(\w+)', t, re.I)
        if m: c['uservars'][m.group(1).lower()] = 0
        return
    # flags: may be several per line
    if t.startswith('+') or t.startswith('-'):
        for f in re.findall(r'([+\-])([\w\.]+)', t):
            c['flags'][f[1].upper()] = (f[0] == '+')
        return
    t2 = t.rstrip(';').strip()
    if re.match(r'^monster\s*$', t2, re.I): c['flags']['ISMONSTER'] = True; c['flags']['MONSTER'] = True; return
    if re.match(r'^projectile\s*$', t2, re.I): c['flags']['PROJECTILE'] = True; c['flags']['NOGRAVITY'] = True; return
    m = re.match(r'^dropitem\s+"?([\w\-]+)"?\s*(?:,\s*(-?\d+))?\s*(?:,\s*(-?\d+))?', t2, re.I)
    if m:
        c['dropitems'].append((m.group(1), int(m.group(2) or 255), int(m.group(3) or -1), ln)); return
    m = re.match(r'^([\w\.]+)\s+(.+)$', t2)
    if m:
        k = m.group(1).lower(); v = m.group(2).strip()
        if k in PROPKEYS:
            if k in ('painchance', 'damagefactor'):
                mm = re.match(r'^"?(\w+)"?\s*,\s*([\d\.]+)', v)
                if mm:
                    c['props'].setdefault(k + '.' + mm.group(1).lower(), (mm.group(2), ln)); return
                # DECORATE can chain multiple 'PainChance "X", n' on one line
            c['props'].setdefault(k, (v, ln)) if k not in c['props'] else None
            if k in c['props'] and c['props'][k][1] != ln: c['props'][k] = (v, ln)

def build(out):
    classes = {}
    roots = [('/tmp/qzpk/zscript/actors', 'engine'),
             ('/home/claude/rsq_ubqseries/Monsters/zscript', 'rsq')]
    for r, tag in roots:
        for dp, dn, fns in os.walk(r):
            for f in sorted(fns):
                if f.endswith('.zs'): parse_file(os.path.join(dp, f), classes, tag)
    pickle.dump(classes, open(out, 'wb'))
    return classes

def build_decorate(paths, out, tag):
    classes = {}
    for p in paths: parse_file(p, classes, tag)
    pickle.dump(classes, open(out, 'wb'))
    return classes

if __name__ == '__main__':
    cl = build('/tmp/econ3/ladder/scripts/rsq_classes.pkl')
    print(len(cl))
    for k in ['rs_abysscaco2', 'doomimp', 'rs_commonimp', 'rs_abysscacoballs', 'cacodemon', 'lostsoul']:
        c = cl.get(k)
        print(k, c and (c['parent'], c['props'], list(c['flags'])[:10], list(c['labels'].items())[:12], len(c['frames'])))
