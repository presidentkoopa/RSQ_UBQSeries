#!/usr/bin/env python3
"""decorate.py -- a small DECORATE reader for RSQ Gore's tools (gen_gore.py, gore_lint.py). Not a compiler.

Reads a pk3 straight from its zip (read-only), starts from the root DECORATE lumps the engine would parse
(DECORATE, DECORATE.*, in sorted path order like a pk3's directory), follows #include (quoted or bare, full path from the
pk3 root first, then relative to the including file; case-insensitive), and returns one record per actor:

    name, parent, replaces, source (pk3 short name : path), flags set/cleared, Radius/Height, Translation, BounceType,
    and the States block parsed into states (one per frame letter), labels and flow (stop / loop / wait / fail / goto).

Class names are case-insensitive everywhere (keys are lower case; the record keeps the spelling of the definition).
A class defined twice keeps its FIRST definition, as the engine does (thingdef_parse.cpp: the later one is renamed
'Name@file' with a warning); the later definitions are kept in `dups` for the report.
"""
import re
import zipfile
import posixpath

SPAWN_FUNCS = ('A_SpawnItemEx', 'A_SpawnItem', 'A_CustomMissile', 'A_SpawnProjectile', 'A_FireCustomMissile',
               'A_SpawnDebris', 'A_TossGib', 'A_DropItem', 'Spawn')
SPAWN_RE = re.compile(r'\b(' + '|'.join(SPAWN_FUNCS) + r')\s*\(\s*"([^"]+)"', re.I)
JUMP_RE = re.compile(r'\bA_(?:Jump\w*|Check\w*)\s*\(', re.I)
MODIFIERS = {'bright', 'fast', 'slow', 'nodelay', 'canraise'}
MODIFIERS_ARGS = {'light', 'offset'}
FLOW = {'stop', 'loop', 'wait', 'fail'}


# ------------------------------------------------------------------ text helpers
def strip_comments(t):
    """Remove // and /* */ comments, keep strings and every newline (state lines are newline-sensitive)."""
    out, i, n = [], 0, len(t)
    while i < n:
        c = t[i]
        if c == '"':
            j = i + 1
            while j < n and t[j] != '"':
                if t[j] == '\\':
                    j += 1
                j += 1
            out.append(t[i:j + 1]); i = j + 1
        elif t.startswith('//', i):
            j = t.find('\n', i)
            i = n if j < 0 else j
        elif t.startswith('/*', i):
            j = t.find('*/', i + 2)
            seg = t[i:n if j < 0 else j + 2]
            out.append('\n' * seg.count('\n'))
            i = n if j < 0 else j + 2
        else:
            out.append(c); i += 1
    return ''.join(out)


def match_brace(t, i, open_='{', close='}'):
    """t[i] is the opening brace; return the index of its match (strings respected), or len(t)-1."""
    depth, n = 0, len(t)
    while i < n:
        c = t[i]
        if c == '"':
            i += 1
            while i < n and t[i] != '"':
                if t[i] == '\\':
                    i += 1
                i += 1
        elif c == open_:
            depth += 1
        elif c == close:
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return n - 1


def strip_strings(t):
    return re.sub(r'"(?:[^"\\]|\\.)*"', '""', t)


# ------------------------------------------------------------------ the pk3
class Pk3:
    def __init__(self, path, short):
        self.path, self.short = path, short
        self.z = zipfile.ZipFile(path)
        self.names = {}
        for n in self.z.namelist():
            if not n.endswith('/'):
                self.names.setdefault(n.replace('\\', '/').lower(), n)

    def read(self, lname):
        return self.z.read(self.names[lname]).decode('latin-1')

    def roots(self):
        """Root-level DECORATE lumps: 'decorate' or 'decorate.<ext>' with no directory."""
        return sorted(k for k in self.names if '/' not in k and k.split('.', 1)[0] == 'decorate')

    def resolve_include(self, inc, cur):
        inc = inc.replace('\\', '/').lower().lstrip('/')
        if inc in self.names:
            return inc
        rel = posixpath.normpath(posixpath.join(posixpath.dirname(cur), inc))
        return rel if rel in self.names else None


# ------------------------------------------------------------------ states
class States:
    """One defining class's States block. S[i] = state dict; nxt[i] = what follows state i."""

    def __init__(self):
        self.S = []          # {'tics': (lo, hi), 'action': str, 'sprite': str}
        self.nxt = []        # ('seq',) | ('stop',) | ('loop', idx) | ('wait',) | ('goto', target) | ('fail',)
        self.labels = {}     # lower label -> ('idx', i) | ('flow', flowtuple)
        self.order = []      # label names in definition order (lower)


def _parse_tics(tok):
    m = re.match(r'random\s*\(\s*(-?\d+)\s*,\s*(-?\d+)\s*\)', tok, re.I)
    if m:
        a, b = int(m.group(1)), int(m.group(2))
        return (min(a, b), max(a, b))
    try:
        v = int(float(tok))
        return (v, v)
    except ValueError:
        return (0, 0)


def parse_states(t):
    st = States()
    i, n = 0, len(t)
    pending = []          # labels waiting for their first state
    last_label_idx = 0    # where `loop` goes
    crossed = True

    def skip_ws():
        nonlocal i, crossed
        while i < n and (t[i].isspace() or t[i] == ';'):
            if t[i] == '\n':
                crossed = True
            i += 1

    def read_word():
        nonlocal i
        if i < n and t[i] == '"':
            j = t.find('"', i + 1)
            j = n - 1 if j < 0 else j
            w = t[i + 1:j]; i = j + 1
            return w
        j = i
        while j < n and not t[j].isspace() and t[j] not in '(){}:,;"':
            j += 1
        if j == i:           # a lone punctuation character
            j = i + 1
        w = t[i:j]; i = j
        return w

    def read_parens():
        nonlocal i
        j = match_brace(t, i, '(', ')')
        s = t[i:j + 1]; i = j + 1
        return s

    def flow_to(f):
        for lb in pending:
            st.labels[lb] = ('flow', f)
        pending.clear()
        if st.S:
            st.nxt[-1] = f

    while True:
        crossed = False
        skip_ws()
        if i >= n:
            break
        w = read_word()
        if not w:
            continue
        # a label: word followed by ':' (not '::')
        k = i
        while k < n and t[k] in ' \t':
            k += 1
        if k < n and t[k] == ':' and not t.startswith('::', k):
            i = k + 1
            lb = w.lower()
            pending.append(lb)
            st.order.append(lb)
            last_label_idx = len(st.S)
            continue
        wl = w.lower()
        if wl in FLOW:
            if wl == 'loop':
                flow_to(('loop', last_label_idx))
            else:
                flow_to((wl,))
            continue
        if wl == 'goto':
            j = t.find('\n', i)
            j = n if j < 0 else j
            target = t[i:j].strip().rstrip(';').strip()
            i = j
            flow_to(('goto', target))
            continue
        # a frame: sprite frames tics [modifiers] [action]
        sprite = w
        crossed = False
        skip_ws()
        frames = read_word()
        skip_ws()
        if t[i:i + 6].lower() == 'random':
            i += 6
            while i < n and t[i] in ' \t':
                i += 1
            tics = _parse_tics('random' + read_parens())
        else:
            tics = _parse_tics(read_word())
        action = ''
        bright = False
        nodelay = False
        while True:
            crossed = False
            save = i
            skip_ws()
            if crossed or i >= n:
                i = save
                break
            if t[i] == '{':
                j = match_brace(t, i)
                action = t[i:j + 1]; i = j + 1
                break
            w2 = read_word()
            if w2.lower() in MODIFIERS:
                bright |= w2.lower() == 'bright'
                nodelay |= w2.lower() == 'nodelay'
                continue
            if w2.lower() in MODIFIERS_ARGS:
                while i < n and t[i] in ' \t':
                    i += 1
                if i < n and t[i] == '(':
                    read_parens()
                continue
            action = w2
            k = i
            while k < n and t[k] in ' \t':
                k += 1
            if k < n and t[k] == '(':
                i = k
                action += read_parens()
            break
        count = max(1, len(frames))
        for ch in (frames or 'A')[:count]:
            # 'frame' (the letter) and 'bright' feed the phase 1 cards (cards.py); the table only reads tics/action.
            # 'nodelay': a Spawn state's first action runs on spawn only with NoDelay (cards.py explore)
            st.S.append({'tics': tics, 'action': action, 'sprite': sprite.upper(), 'frame': ch.upper(),
                         'bright': bright, 'nodelay': nodelay})
            st.nxt.append(('seq',))
        for lb in pending:
            st.labels[lb] = ('idx', len(st.S) - count)
        pending.clear()
    for lb in pending:          # labels at the very end: fall off = stop
        st.labels[lb] = ('flow', ('stop',))
    return st


# ------------------------------------------------------------------ actors
FLAG_RE = re.compile(r'(?<![\w.])([+-])\s*([A-Za-z_][A-Za-z0-9_.]*)')
BOUNCE_FLAGS = {'doombounce', 'hereticbounce', 'hexenbounce', 'bounceonwalls', 'bounceonfloors', 'bounceonceilings',
                'bounceonactors', 'allowbounceonactors', 'bounceautooff', 'bounceautooffflooronly', 'bouncelikeheretic'}
PROJECTILE_FLAGS = ('noblockmap', 'nogravity', 'dropoff', 'missile', 'impact', 'pcross', 'noteleport')
PROP_KEYS = {'speed', 'gravity', 'scale', 'xscale', 'yscale', 'alpha', 'renderstyle', 'decal', 'radius', 'height',
             'bouncefactor', 'wallbouncefactor', 'mass'}
MONSTER_FLAGS = ('shootable', 'countkill', 'solid', 'canpushwalls', 'canusewalls', 'activatemcross', 'canpass', 'ismonster')


class Actor:
    def __init__(self, name, parent, replaces, source, body):
        self.name, self.parent, self.replaces, self.source = name, parent, replaces, source
        self.key = name.lower()
        self.pkey = parent.lower() if parent else None
        self.flags = {}              # lower flag -> True (+) / False (-), in order
        self.radius = self.height = None
        self.translation = None
        self.bouncetype = None
        self.states = None
        self.props = {}              # lower key -> value string (PROP_KEYS)
        self._parse_body(body)

    def _parse_body(self, body):
        m = None
        depth, i, n = 0, 0, len(body)
        while i < n:                 # find `states {` at depth 0
            c = body[i]
            if c == '"':
                i = body.find('"', i + 1)
                if i < 0:
                    break
            elif c == '{':
                depth += 1
            elif c == '}':
                depth -= 1
            elif depth == 0 and (i == 0 or not (body[i - 1].isalnum() or body[i - 1] == '_')) \
                    and body[i:i + 6].lower() == 'states':
                mm = re.match(r'states\s*(\([^)]*\))?\s*\{', body[i:], re.I)
                if mm:
                    m = (i, i + mm.end() - 1)
                    break
            i += 1
        props = body
        if m:
            j = match_brace(body, m[1])
            self.states = parse_states(body[m[1] + 1:j])
            props = body[:m[0]] + '\n' + body[j + 1:]
        bare = strip_strings(props)
        for ln in bare.split('\n'):
            s = ln.strip().lower()
            if re.match(r'^projectile\s*$', s):
                for f in PROJECTILE_FLAGS:
                    self.flags[f] = True
            elif re.match(r'^monster\s*$', s):
                for f in MONSTER_FLAGS:
                    self.flags[f] = True
            elif re.match(r'^clearflags\s*$', s):
                self.flags.clear()
        for sign, f in FLAG_RE.findall(bare):
            self.flags[f.lower()] = (sign == '+')
        mm = re.search(r'^\s*radius\s+([-\d.]+)', props, re.I | re.M)
        if mm:
            self.radius = float(mm.group(1))
        mm = re.search(r'^\s*height\s+([-\d.]+)', props, re.I | re.M)
        if mm:
            self.height = float(mm.group(1))
        mm = re.search(r'^\s*translation\s+((?:"[^"]*"\s*,?\s*)+|[\w]+)', props, re.I | re.M)
        if mm:
            self.translation = re.sub(r'\s+', ' ', mm.group(1).strip().rstrip(','))
        mm = re.search(r'^\s*bouncetype\s+"?(\w+)', props, re.I | re.M)
        if mm:
            self.bouncetype = mm.group(1).lower()
        # The single-value properties phase 1's cards read (cards.py), by token so one-line bodies such as
        # `{ scale 3.0 speed 12 }` read too. Values stay strings; the last one written wins, as in DECORATE.
        toks = re.findall(r'"[^"]*"|[^\s{};,]+', props)
        for k, tok in enumerate(toks[:-1]):
            key = tok.lower()
            if key in PROP_KEYS and not tok.startswith('"'):
                self.props[key] = toks[k + 1].strip('"')


def read_pk3(path, short):
    """Every actor of one pk3, in parse order: (list of Actor, list of (include, from) not found, files parsed)."""
    pk = Pk3(path, short)
    actors, missing, files, seen = [], [], [], set()

    def parse_file(lname):
        if lname in seen:
            return
        seen.add(lname)
        files.append(lname)
        t = strip_comments(pk.read(lname))
        i, n = 0, len(t)
        while i < n:
            if t[i].isspace() or t[i] == ';':
                i += 1
                continue
            if t[i] == '#':
                mm = re.match(r'#include\s+(?:"([^"]+)"|(\S+))', t[i:], re.I)
                if mm:
                    inc = mm.group(1) or mm.group(2)
                    r = pk.resolve_include(inc, lname)
                    if r:
                        parse_file(r)
                    else:
                        missing.append((inc, lname))
                    i += mm.end()
                    continue
            mm = re.match(r'actor\s+([^{]*)\{', t[i:], re.I)
            if mm and (i == 0 or not (t[i - 1].isalnum() or t[i - 1] == '_')):
                header = mm.group(1).replace(':', ' : ').split()
                j = match_brace(t, i + mm.end() - 1)
                body = t[i + mm.end():j]
                name, parent, repl = header[0], None, None
                k = 1
                while k < len(header):
                    h = header[k].lower()
                    if h == ':' and k + 1 < len(header):
                        parent = header[k + 1]; k += 2; continue
                    if h == 'replaces' and k + 1 < len(header):
                        repl = header[k + 1]; k += 2; continue
                    k += 1
                actors.append(Actor(name, parent, repl, '%s:%s' % (short, pk.names[lname]), body))
                i = j + 1
                continue
            mm = re.match(r'(const|enum)\b', t[i:], re.I)
            if mm:
                j = i
                while j < n and t[j] != ';':
                    if t[j] == '{':
                        j = match_brace(t, j)
                    j += 1
                i = j + 1
                continue
            if t[i] == '{':
                i = match_brace(t, i) + 1
                continue
            i += 1

    for r in pk.roots():
        parse_file(r)
    return actors, missing, files


class World:
    """Both packs' actors, BD first then XMVE (load order); first definition of a name wins."""

    def __init__(self, packs):
        self.cls, self.dups, self.missing, self.files = {}, [], [], {}
        self.order = []
        for path, short in packs:
            actors, missing, files = read_pk3(path, short)
            self.missing += [(short, a, b) for a, b in missing]
            self.files[short] = files
            for a in actors:
                if a.key in self.cls:
                    self.dups.append((a.name, self.cls[a.key].source, a.source))
                    continue
                self.cls[a.key] = a
                self.order.append(a.key)
        self.children = {}
        for k in self.order:
            p = self.cls[k].pkey
            if p:
                self.children.setdefault(p, []).append(k)

    # ---- inheritance
    def chain(self, key):
        out, seen = [], set()
        while key and key in self.cls and key not in seen:
            seen.add(key); out.append(key)
            key = self.cls[key].pkey
        return out

    def engine_parent(self, key):
        """The first ancestor name that is not a DECORATE class in these packs (an engine class), or None."""
        c = self.chain(key)
        last = self.cls[c[-1]] if c else None
        return last.parent if last else None

    def descendants(self, key):
        out, stack = [], [key]
        while stack:
            k = stack.pop()
            for c in self.children.get(k, []):
                out.append(c); stack.append(c)
        return out

    def flags(self, key):
        eff = {}
        for k in reversed(self.chain(key)):
            a = self.cls[k]
            if a.flags == {} and False:
                pass
            for f, v in a.flags.items():
                eff[f] = v
            if a.bouncetype is not None:
                eff['_bounce'] = a.bouncetype not in ('none', '0')
        return eff

    def prop(self, key, attr):
        for k in self.chain(key):
            v = getattr(self.cls[k], attr)
            if v is not None:
                return v
        return None

    def pval(self, key, name, default=None):
        """A PROP_KEYS property through inheritance (own value first), or `default` (the engine's)."""
        for k in self.chain(key):
            v = self.cls[k].props.get(name)
            if v is not None:
                return v
        return default

    # ---- states
    def states_of(self, key):
        """(definer key, States) of the nearest class in the chain that has a States block."""
        for k in self.chain(key):
            if self.cls[k].states is not None:
                return k
        return None

    def find_label(self, key, label):
        """Resolve a label for class `key` (own labels, then inherited). Returns (definer, ('idx', i)|('flow', f)) or None."""
        label = label.lower()
        for k in self.chain(key):
            st = self.cls[k].states
            if st is not None and label in st.labels:
                return k, st.labels[label]
        return None

    def goto(self, definer, target):
        """Resolve 'goto X[+n]' written in `definer`'s States. Returns (key, idx) or None."""
        m = re.match(r'([\w.]+)(?:\s*::\s*([\w.]+))?\s*(?:\+\s*(\d+))?', target)
        if not m:
            return None
        off = int(m.group(3) or 0)
        if m.group(2):
            scope, label = m.group(1).lower(), m.group(2)
            if scope == 'super':
                start = self.cls[definer].pkey
            else:
                start = scope
            if not start or start not in self.cls:
                return None
            r = self.find_label(start, label)
        else:
            r = self.find_label(definer, m.group(1))
        if not r:
            return None
        k, ref = r
        if ref[0] == 'flow':
            return ('flow', k, ref[1])
        return (k, ref[1] + off)
