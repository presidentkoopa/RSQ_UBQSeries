"""DECORATE -> ZScript for Weapons of Saturn's NON-weapon actors (ammo, items, effects, projectiles, player classes).
The weapons themselves are hand-written (src/zscript/wos/). Mechanical only: anything it cannot carry over cleanly
(ACS, unknown syntax) is marked `// DEC2ZS:` in the output and listed on stdout, never silently dropped.

usage: dec2zs.py <out.zs> <file.txt> [...] [--skip Actor,Actor] [--rename Old=New,...]
"""
import re, sys

DEPRECATED = [
    # name, function(args_list) -> replacement string
]

def split_args(s):
    out, depth, cur, q = [], 0, '', False
    for ch in s:
        if ch == '"': q = not q
        if not q and ch == '(': depth += 1
        if not q and ch == ')': depth -= 1
        if not q and ch == ',' and depth == 0:
            out.append(cur.strip()); cur = ''; continue
        cur += ch
    if cur.strip(): out.append(cur.strip())
    return out

CHAN = {'"weapon"': 'CHAN_WEAPON', '"body"': 'CHAN_BODY', '"voice"': 'CHAN_VOICE', '"item"': 'CHAN_ITEM', '"auto"': 'CHAN_AUTO',
        '"soundslot5"': '5', '"soundslot6"': '6', '"soundslot7"': '7'}

def fix_call(name, args):
    n = name.lower()
    if n == 'a_custommissile':
        return 'A_SpawnProjectile(%s)' % ', '.join(args)
    if n == 'a_firecustommissile':
        return 'A_FireProjectile(%s)' % ', '.join(args)
    if n == 'a_playsound':
        s = args[0] if args else '""'
        slot = args[1] if len(args) > 1 else 'CHAN_BODY'
        vol = args[2] if len(args) > 2 else '1.0'
        loop = args[3] if len(args) > 3 else 'false'
        att = args[4] if len(args) > 4 else 'ATTN_NORM'
        flags = 'CHANF_LOOPING' if loop.lower() in ('true', '1') else '0'
        if len(args) <= 2:
            return 'A_StartSound(%s, %s)' % (s, slot)
        return 'A_StartSound(%s, %s, %s, %s, %s)' % (s, slot, flags, vol, att)
    if n == 'a_playsoundex':
        s = args[0]; ch = CHAN.get(args[1].lower(), 'CHAN_AUTO') if len(args) > 1 else 'CHAN_AUTO'
        loop = len(args) > 2 and args[2].lower() in ('true', '1')
        return 'A_StartSound(%s, %s%s)' % (s, ch, ', CHANF_LOOPING' if loop else '')
    if n == 'a_stopsoundex':
        return 'A_StopSound(%s)' % (CHAN.get(args[0].lower(), 'CHAN_AUTO') if args else 'CHAN_AUTO')
    if n == 'a_playweaponsound':
        return 'A_StartSound(%s, CHAN_WEAPON)' % args[0]
    if n == 'a_spawnitem':
        # A_SpawnItem(type, distance, zheight, useammo, transfer_translation) -> A_SpawnItemEx at that distance
        t = args[0] if args else '""'
        dist = args[1] if len(args) > 1 else '0'
        zh = args[2] if len(args) > 2 else '0'
        return 'A_SpawnItemEx(%s, %s, 0, %s)' % (t, dist, zh)
    return None

CALL = re.compile(r'\b(A_[A-Za-z0-9_]+)\s*\(')

def fix_calls(s):
    out, i = '', 0
    while True:
        m = CALL.search(s, i)
        if not m:
            out += s[i:]; break
        # find matching paren
        j, depth, q = m.end(), 1, False
        while j < len(s) and depth:
            if s[j] == '"': q = not q
            elif not q and s[j] == '(': depth += 1
            elif not q and s[j] == ')': depth -= 1
            j += 1
        args = split_args(s[m.end():j - 1])
        args = [fix_calls(a) for a in args]
        rep = fix_call(m.group(1), args)
        out += s[i:m.start()] + (rep if rep else '%s(%s)' % (m.group(1), ', '.join(args)))
        i = j
    return out

def fix_expr(s):
    s = re.sub(r'\bmomz\b', 'vel.z', s, flags=re.I)
    s = re.sub(r'\bmomx\b', 'vel.x', s, flags=re.I)
    s = re.sub(r'\bmomy\b', 'vel.y', s, flags=re.I)
    return s

FRAME = re.compile(r'^(\s*)("?[A-Za-z0-9_#\-]{4}"?)\s+("?[A-Za-z\[\]\\\^#]+"?)\s+(-?\d+|random\s*\([^)]*\))(.*)$', re.I)

# WoS's ACS option reads, at their CVARINFO defaults (the options are gone: SPEC Q2). CheckPlayerClass is called by
# the mod but no such script exists in it: ACS returns 0 for a missing script.
ACS_DEFAULT = {'smokeeffects': 1, 'shellcasings': 1, 'helmetbonus': 1, 'zombiefullauto': 0, 'classicpump': 0,
               'checkplayerclass': 0, 'backpackguns': 0}
ACSJ = re.compile(r'A_JumpIf\s*\(\s*(?:ACS_NamedExecuteWithResult|CallACS)\s*\(\s*"([A-Za-z0-9_]+)"[^)]*\)\s*(==|!=)\s*(-?\d+)\s*,\s*([^)]+)\)', re.I)

def acs_line(st, notes, cur):
    m = ACSJ.search(st)
    if not m or m.group(1).lower() not in ACS_DEFAULT:
        return None
    v = ACS_DEFAULT[m.group(1).lower()]
    cond = (v == int(m.group(3))) if m.group(2) == '==' else (v != int(m.group(3)))
    rep = 'A_Jump(256, %s)' % m.group(4).strip() if cond else ''
    notes.append('%s: ACS %s read at its default %d: %s' % (cur, m.group(1), v, 'always jumps' if cond else 'never jumps (kept as a no-op frame)'))
    out = (st[:m.start()] + rep + st[m.end():]).rstrip()
    return out

INVFLAGS = {'invbar', 'undroppable', 'ignoreskill', 'alwayspickup', 'autoactivate', 'untossable', 'quiet', 'fancypickupsound',
            'bigpowerup', 'keepdepleted', 'hubpower', 'persistentpower', 'interhubstrip', 'pickupflash', 'noscreenflash',
            'noattenpickupsound', 'restrictabsolutely', 'neverrespawn', 'nottimefreeze', 'isarmor', 'ishealth',
            'unclearable', 'additivetime', 'alwaysrespawn', 'transfer', 'tossed', 'nodrain', 'noteleportfreeze'}
def fixflag(t):
    sign, name = t[0], t[1:]
    if name.lower() == 'doombounce':
        return 'BounceType "Doom";' if sign == '+' else 'BounceType "None";'
    if '.' not in name and name.lower() in INVFLAGS:
        return sign + 'INVENTORY.' + name.upper()
    return t

def convert(text, skip, rename, notes, fname):
    text = text.replace('\r', '').replace('\ufeff', '').replace('\xef\xbb\xbf', '')
    text = re.sub(r'/\*.*?\*/', lambda m: '\n' * m.group(0).count('\n'), text, flags=re.S)
    text = re.sub(r'^(\s*)([+-])\s+([A-Za-z])', r'\1\2\3', text, flags=re.M)
    lines = text.split('\n')
    out = []
    i = 0
    state = None  # None, 'props', 'states'
    depth = 0
    cur = None
    def R(name):
        return rename.get(name.lower(), name)
    skipping = False
    while i < len(lines):
        raw = lines[i]; i += 1
        line = raw.rstrip()
        code, cmt = line, ''
        # split off // comments outside strings
        q = False
        for k, ch in enumerate(line):
            if ch == '"': q = not q
            if not q and line[k:k + 2] == '//':
                code, cmt = line[:k].rstrip(), line[k:]; break
        st = code.strip()
        m = re.match(r'^actor\s+("?)([A-Za-z0-9_]+)\1\s*(?::\s*("?)([A-Za-z0-9_]+)\3)?\s*(?:replaces\s+("?)([A-Za-z0-9_]+)\5)?\s*(\d+)?\s*(\{)?\s*$', st, re.I)
        if state is None and m:
            name, parent, repl, ednum, brace = m.group(2), m.group(4), m.group(6), m.group(7), m.group(8)
            cur = name
            skipping = name.lower() in skip
            if not skipping:
                hdr = 'class %s' % R(name)
                hdr += ' : %s' % R(parent) if parent else ' : Actor'
                if repl: hdr += ' replaces %s' % R(repl)
                out.append('// from %s: ACTOR %s%s' % (fname, name, (' (DoomEdNum %s: set in MAPINFO DoomEdNums if wanted)' % ednum) if ednum else ''))
                out.append(hdr)
                if ednum: notes.append('%s: DoomEdNum %s not carried (ZScript classes take it from MAPINFO)' % (name, ednum))
            state = 'head'; depth = 0
            if brace:
                state = 'props'; depth = 1
                if not skipping: out.append('{'); out.append('\tDefault'); out.append('\t{')
            continue
        if state == 'head':
            if st.startswith('{'):
                state = 'props'; depth = 1
                if not skipping: out.append('{'); out.append('\tDefault'); out.append('\t{')
            continue
        if state is None:
            if st and not skipping and not st.startswith('#include'):
                out.append(('// ' + line) if st else line)
            continue
        # inside an actor
        if skipping:
            depth += code.count('{') - code.count('}')
            if depth <= 0: state = None; skipping = False
            continue
        if state == 'props':
            if re.match(r'^states\s*(\{)?$', st, re.I):
                out.append('\t}'); out.append('\tStates'); out.append('\t{')
                state = 'states'
                if not st.endswith('{'):
                    # brace on next line
                    while i < len(lines) and lines[i].strip() != '{': i += 1
                    i += 1
                depth = 2
                continue
            if st == '}':
                out.append('\t}'); out.append('}'); out.append('')
                state = None
                continue
            if not st:
                if cmt: out.append('\t\t' + cmt)
                continue
            st = ' '.join(fixflag(t) for t in st.split()) if all(re.match(r'^[+-][A-Za-z0-9_.]+$', t) for t in st.split()) else st
            if st.startswith('BounceType'):
                out.append('\t\t%s' % st); continue
            if re.match(r'^[+-][A-Za-z0-9_.]+$', st):
                for fl in st.split():
                    out.append('\t\t%s;%s' % (fl, ('\t' + cmt) if cmt else ''))
                continue
            # several flags on one line
            if all(re.match(r'^[+-][A-Za-z0-9_.]+$', t) for t in st.split()):
                out.append('\t\t' + ' '.join(t + ';' for t in st.split()))
                continue
            if re.match(r'^(monster|projectile)$', st, re.I):
                out.append('\t\t%s;' % st.capitalize()); continue
            mprop = re.match(r'^([A-Za-z][A-Za-z0-9_.]*)\s*(.*)$', st)
            if mprop:
                key, val = mprop.group(1), mprop.group(2).strip()
                val = re.sub(r'("[^"]*")\s+(-?\d)', r'\1, \2', val)
                # a lone bare word is a string in ZScript (an icon, a class, a colourmap name); classes get the prefix
                if re.match(r'^[A-Za-z_][A-Za-z0-9_]*$', val) and val.lower() not in ('true', 'false'):
                    val = '"%s"' % rename.get(val.lower(), val)
                if key.lower() == 'damage' and val.startswith('('):
                    out.append('\t\tDamageFunction %s;%s' % (val, ('\t' + cmt) if cmt else '')); continue
                if key.lower() == 'renderstyle' and not val.startswith('"'):
                    val = '"%s"' % val
                if key.lower() in ('decal', 'damagetype', 'obituary', 'tag') and not val.startswith('"'):
                    val = '"%s"' % val
                val = re.sub(r'(?<=[^,\s])\s+(?=-?\d)', ', ', val) if key.lower() in ('player.colorrange', 'player.damagescreencolor') else val
                val = re.sub(r'"?\b([A-Za-z0-9_]+)\b"?', lambda q: ('"%s"' % rename[q.group(1).lower()]) if q.group(1).lower() in rename and key.lower() in ('dropitem', 'player.startitem', 'powerup.type', 'weapon.ammotype', 'weapon.ammotype1', 'weapon.ammotype2', 'ammo.dropamount') else q.group(0), val, count=1)
                out.append('\t\t%s %s;%s' % (key, val, ('\t' + cmt) if cmt else ''))
                continue
            out.append('\t\t// DEC2ZS: %s' % line.strip()); notes.append('%s: property line kept as a comment: %s' % (cur, st))
            continue
        if state == 'states':
            depth += code.count('{') - code.count('}')
            if depth <= 1:
                out.append('\t}'); out.append('}'); out.append('')
                state = None
                continue
            if not st:
                if cmt: out.append('\t\t' + cmt)
                continue
            if re.search(r'\bACS_|CallACS', st, re.I):
                al = acs_line(st, notes, cur)
                if al is None:
                    out.append('\t\t// DEC2ZS (ACS, needs a hand port): %s' % st); notes.append('%s: ACS in a state: %s' % (cur, st))
                    continue
                st = al
            lab = re.match(r'^([A-Za-z0-9_.]+)\s*:\s*(.*)$', st)
            if lab and not FRAME.match(st):
                out.append('\t%s:' % lab.group(1))
                rest = lab.group(2).strip()
                if not rest:
                    if cmt: out[-1] += '\t' + cmt
                    continue
                st = rest
            low = st.lower()
            if re.match(r'^(loop|stop|wait|fail)$', low):
                out.append('\t\t%s;%s' % (st.capitalize(), ('\t' + cmt) if cmt else '')); continue
            mg = re.match(r'^goto\s+(.+)$', st, re.I)
            if mg:
                out.append('\t\tGoto %s;%s' % (mg.group(1).strip(), ('\t' + cmt) if cmt else '')); continue
            fm = FRAME.match(st)
            if fm:
                body = fix_expr(fix_calls(st))
                body = re.sub(r'"([A-Za-z0-9_]+)"', lambda q: '"%s"' % rename.get(q.group(1).lower(), q.group(1)), body)
                if body.rstrip().endswith('}'):
                    out.append('\t\t%s%s' % (body, ('\t' + cmt) if cmt else ''))
                else:
                    out.append('\t\t%s;%s' % (body, ('\t' + cmt) if cmt else ''))
                continue
            out.append('\t\t// DEC2ZS: %s' % st); notes.append('%s: state line kept as a comment: %s' % (cur, st))
    return '\n'.join(out)

def main():
    a = sys.argv[1:]
    skip, rename, prefix = set(), {}, None
    files = []
    k = 0
    while k < len(a):
        if a[k] == '--skip': skip = set(x.lower() for x in a[k + 1].split(',')); k += 2; continue
        if a[k] == '--prefix':
            prefix = a[k + 1]; k += 2; continue
        if a[k] == '--rename':
            for p in a[k + 1].split(','):
                o, n = p.split('='); rename[o.lower()] = n
            k += 2; continue
        files.append(a[k]); k += 1
    outp, srcs = files[0], files[1:]
    if prefix:
        # every actor these files define gets the prefix (byte-order marks stripped first)
        for f in srcs:
            t = open(f, encoding='latin-1').read().replace('\r', '').replace('\xef\xbb\xbf', '')
            for m in re.finditer(r'(?im)^\s*actor\s+"?([A-Za-z0-9_]+)', t):
                rename.setdefault(m.group(1).lower(), prefix + m.group(1))
    notes = []
    body = ['// GENERATED by tools/dec2zs.py from Weapons of Saturn\'s DECORATE (the non-weapon actors). Hand fixes go in',
            '// the files that include this one, never in here: regenerate instead.', '']
    for f in srcs:
        body.append(convert(open(f, encoding='latin-1').read(), skip, rename, notes, f.split('/')[-1]))
    open(outp, 'w').write('\n'.join(body) + '\n')
    for n in notes: print('NOTE', n)

if __name__ == '__main__':
    main()
