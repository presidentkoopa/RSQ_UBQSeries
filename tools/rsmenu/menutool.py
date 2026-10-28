#!/usr/bin/env python3
"""menutool.py -- measure and check the series' MENUDEFs (no guessing: parsed).

  menutool.py count <MENUDEF>...            pages / rows / sliders, per page and total
  menutool.py defaults <CVARINFO>           name = default, one per line
  menutool.py check <mod folder>            every page reachable from the front page, every cvar a
                                            row names exists, every preset's "Standard" equals the
                                            CVARINFO defaults, every cvar that had a row still has one
Rows = every item but StaticText; sliders = Slider rows.
"""
import re, sys, os, glob

ITEM = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s+(.*)$')

def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
    return '\n'.join(re.sub(r'(^|\s)//.*$', '', l) for l in t.split('\n'))

def args_of(rest):
    return re.findall(r'"((?:[^"\\]|\\.)*)"|([^\s,"]+)', rest)

def parse(text):
    """-> (menus{name:[(kind,[args])]}, adds{name:[...]}, optionvalues{name:[(value,text)]}, order[])"""
    text = strip_comments(text)
    toks = re.split(r'(\{|\})', text)
    menus, adds, ovals, order = {}, {}, {}, []
    i = 0
    head = ''
    while i < len(toks):
        t = toks[i]
        if t == '{':
            body, depth, j = [], 1, i + 1
            while j < len(toks) and depth:
                if toks[j] == '{': depth += 1
                elif toks[j] == '}': depth -= 1
                if depth: body.append(toks[j])
                j += 1
            h = head.strip().split('\n')[-1].strip()
            m = re.match(r'(OptionMenu|AddOptionMenu|OptionValue|OptionString)\s+"?([^"\s]+)"?', h, re.I)
            if m:
                kind, name = m.group(1).lower(), m.group(2)
                lines = [l for l in ''.join(body).split('\n') if l.strip()]
                if kind in ('optionmenu', 'addoptionmenu'):
                    rows = []
                    for l in lines:
                        mm = ITEM.match(l)
                        if not mm: continue
                        k = mm.group(1)
                        if k.lower() in ('title', 'class', 'position', 'defaultselection', 'scrolltop', 'indent'): continue
                        a = [x[0] if x[0] or not x[1] else x[1] for x in args_of(mm.group(2))]
                        rows.append((k, a))
                    (menus if kind == 'optionmenu' else adds).setdefault(name, []).extend(rows)
                    if kind == 'optionmenu': order.append(name)
                else:
                    vals = []
                    for l in lines:
                        a = [x[0] if x[0] or not x[1] else x[1] for x in args_of(l)]
                        if len(a) >= 2: vals.append((a[0], a[1]))
                    ovals[name] = vals
            head = ''
            i = j
            continue
        head += t
        i += 1
    return menus, adds, ovals, order

def read_menudefs(paths):
    menus, adds, ovals, order = {}, {}, {}, []
    for p in paths:
        m, a, o, od = parse(open(p, encoding='utf-8', errors='replace').read())
        menus.update(m); ovals.update(o); order += od
        for k, v in a.items(): adds.setdefault(k, []).extend(v)
    return menus, adds, ovals, order

def is_row(k): return k.lower() != 'statictext'

def counts(rows):
    r = [x for x in rows if is_row(x[0])]
    return len(r), sum(1 for x in r if x[0].lower() == 'slider')

def lines(rows): return len(rows)

def reachable(menus, root):
    seen, todo = [], [root]
    while todo:
        n = todo.pop(0)
        if n in seen or n not in menus: continue
        seen.append(n)
        for k, a in menus[n]:
            if k.lower() == 'submenu' or k.lower().endswith('rslink'):
                if len(a) > 1: todo.append(a[1])
    return seen

def cvar_defaults(path):
    d = {}
    for l in open(path, encoding='utf-8', errors='replace'):
        l = re.sub(r'//.*', '', l)
        for m in re.finditer(r'(?:(?:server|user|nosave|noarchive|cheat|latch|nosend|serverinfo)\s+)*(bool|int|float|string|color)\s+(\w+)\s*(?:=\s*([^;]*))?;', l, re.I):
            d[m.group(2).lower()] = (m.group(1).lower(), (m.group(3) or '').strip().strip('"'))
    return d

def num_eq(a, b):
    try: return abs(float(a) - float(b)) < 1e-4
    except ValueError:
        t = {'true': '1', 'false': '0'}
        return t.get(a.lower(), a.lower()) == t.get(b.lower(), b.lower())

def mod_files(folder):
    md = [p for p in glob.glob(os.path.join(folder, '**', '*'), recursive=True)
          if os.path.isfile(p) and re.match(r'menudef', os.path.basename(p), re.I)
          and not re.search(r'/(docs|original|original_1\.04|jp_original|tools|test)/', p)]
    cv = [p for p in glob.glob(os.path.join(folder, '**', '*'), recursive=True)
          if os.path.isfile(p) and re.match(r'cvarinfo', os.path.basename(p), re.I)
          and not re.search(r'/(docs|original|original_1\.04|jp_original|tools|test)/', p)]
    return md, cv

def front_of(menus, adds):
    for k, a in adds.get('RSQ_RSOptions', []) + adds.get('OptionsMenu', []):
        if len(a) > 1 and a[1] in menus and a[1] != 'RSQ_RSOptions': return a[1]
    return None

def main():
    cmd = sys.argv[1]
    if cmd == 'count':
        menus, adds, ovals, order = read_menudefs(sys.argv[2:])
        tot_r = tot_s = 0
        for n in order:
            r, s = counts(menus[n]); tot_r += r; tot_s += s
            print(f'  {n:28s} rows {r:4d}  sliders {s:3d}')
        print(f'TOTAL pages {len(order)} rows {tot_r} (lines incl. spacers {sum(lines(menus[n]) for n in order)}) sliders {tot_s}')
    elif cmd == 'defaults':
        for k, (t, v) in cvar_defaults(sys.argv[2]).items(): print(f'{k} = {v}')
    elif cmd == 'check':
        folder = sys.argv[2]
        md, cv = mod_files(folder)
        menus, adds, ovals, order = read_menudefs(md)
        defs = {}
        for p in cv: defs.update(cvar_defaults(p))
        bad = 0
        front = front_of(menus, adds)
        if not front: print('NO FRONT PAGE linked from RSQ_RSOptions'); return 1
        seen = reachable(menus, front)
        own = [n for n in order if n not in ('RSQ_RSOptions', 'TopHPBars_Settings') and not n.startswith('GunBonsai')]
        for n in set(own):
            if own.count(n) > 1: print(f'DUPLICATE page {n} (defined {own.count(n)} times)'); bad += 1
        own = list(dict.fromkeys(own))
        if 'RSQ_RSOptions' not in order: print('NO protected RSQ_RSOptions definition'); bad += 1
        links = [a for k, a in adds.get('OptionsMenu', []) if k.lower().endswith('rslink')]
        if len(links) != 1 or links[0][1] != 'RSQ_RSOptions': print('Options link is not one RSLink row to RSQ_RSOptions'); bad += 1
        for k, a in adds.get('OptionsMenu', []):
            if not k.lower().endswith('rslink'): print(f'a row of its own in Options: {a}'); bad += 1
        for n in own:
            if n not in seen: print(f'ORPHAN page {n}'); bad += 1
        fr, fs = counts(menus[front])
        tr = sum(counts(menus[n])[0] for n in own); ts = sum(counts(menus[n])[1] for n in own)
        print(f'{os.path.basename(folder.rstrip("/"))}: front {front} rows {fr} (lines {lines(menus[front])}) sliders {fs}; pages {len(own)} rows {tr} (lines {sum(lines(menus[n]) for n in own)}) sliders {ts}')
        named = set()
        for n in own:
            for k, a in menus[n]:
                kl = k.lower()
                if kl in ('option', 'slider', 'colorpicker', 'textfield', 'numberfield') and len(a) > 1:
                    c = a[1].lower(); named.add(c)
                    if c not in defs and not c.startswith(('vr_', 'gl_', 'snd_')): print(f'  row {a[0]!r} names unknown cvar {c}'); bad += 1
                if kl.endswith('preset') and len(a) > 1:
                    ov = ovals.get(a[1])
                    if not ov: print(f'  preset {a[0]!r}: no OptionString {a[1]}'); bad += 1; continue
                    std = [v for v in ov if v[1].lower() == 'standard'] or [ov[0]]
                    for val, txt in ov:
                        pr = val.split()
                        for c, v in zip(pr[0::2], pr[1::2]):
                            named.add(c.lower())
                            if c.lower() not in defs: print(f'  preset {a[0]!r}/{txt}: unknown cvar {c}'); bad += 1
                    if len([v for v in ov if v[1].lower() == 'standard']):
                        pr = std[0][0].split()
                        for c, v in zip(pr[0::2], pr[1::2]):
                            if c.lower() in defs and not num_eq(defs[c.lower()][1], v):
                                print(f'  preset {a[0]!r}: Standard sets {c} {v}, default is {defs[c.lower()][1]}'); bad += 1
        if len(sys.argv) > 3:   # a list of cvars that had rows before: each must still have one
            for c in open(sys.argv[3]).read().split():
                if c not in named: print(f'  LOST ROW for cvar {c}'); bad += 1
        print('  OK' if not bad else f'  {bad} problem(s)')
        return 1 if bad else 0
    elif cmd == 'named':   # cvars named by rows in a mod's pages (for the before list)
        md, cv = mod_files(sys.argv[2])
        menus, adds, ovals, order = read_menudefs(md)
        out = set()
        for n in order:
            for k, a in menus[n]:
                if k.lower() in ('option', 'slider', 'colorpicker', 'textfield', 'numberfield') and len(a) > 1: out.add(a[1].lower())
        print(' '.join(sorted(out)))
if __name__ == '__main__':
    sys.exit(main() or 0)
