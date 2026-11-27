#!/usr/bin/env python3
"""chunk_lint.py -- RSQ Gore phase 3's lint (chunk_gen.py's outputs). Exits 1 on any problem, 0 when clean.

    python -I Gore/tools/chunk_lint.py <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>

Also callable from gore_lint.py: chunk_lint.check(bd, xm, bad, note, strict=True).

  - the outputs are current: chunk_gen.py run now into a temporary folder gives zscript/rsqgo/chunk_cards.zs,
    MODELDEF.chunks and generated/chunk_summary.txt byte for byte;
  - every RSQGO_G_ class is a phase 3 (meat+guts, limb, casing), Gore-owned row of the takeover table, never RSQ
    Score's, never an excluded class; every table row of those categories has a class or is listed as left to BD;
  - per generated class: no label defined twice (labels ignore case), every goto and every quoted jump label exists in
    the class, its generated parents or Actor's own labels, a flier's GibOf names a class above it, no Default flag
    outside the engine's flag list (thingdef_data.cpp), no BD class name used as a class constant;
  - the shared bases (RSQGO_GB_*): never in the takeover table, no Default, each one a parent of a class; and every
    class runs the same states as a flattened render of it would (labels inherited and overridden, gotos resolved in
    the class that wrote them, quoted jump labels in the actor's class): same_as_flat();
  - every RSQGO_ call the generated states make is defined in chunks.zs; no class name is declared twice across Gore's
    ZScript (case-insensitive); MODELDEF.chunks names only generated classes;
  - THE HOOKS (zscript.txt includes, the manager's gibs field and CheckReplacement call, build.sh packing
    MODELDEF.chunks): notes when run alone (they are applied by hand), problems when strict (from gore_lint.py).
"""
import os
import re
import shutil
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import chunk_gen  # noqa: E402  (keeps decorate bodies; must come before gen_gore builds)
import gen_gore  # noqa: E402

GORE = gen_gore.GORE
ACTOR_BUILTIN = {'null', 'genericfreezedeath', 'genericcrush', 'diefromspawn', 'spawn'}
GEN_LABEL = re.compile(r'^[RB]\d+_\d+$', re.I)


def read(p):
    try:
        return open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        return None


def strip_c(t):
    t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
    return re.sub(r'//[^\n]*', '', t)


def classes_in(t):
    """[(name, parent, body)] for every top-level class in a generated file."""
    out = []
    for m in re.finditer(r'^class\s+(\w+)\s*:\s*(\w+)\s*\{', t, re.M):
        i, depth = m.end(), 1
        while i < len(t) and depth:
            if t[i] == '{':
                depth += 1
            elif t[i] == '}':
                depth -= 1
            i += 1
        out.append((m.group(1), m.group(2), t[m.end():i - 1]))
    return out


def check(bd, xm, bad, note, strict=False):
    out = {k: os.path.join(GORE, v) for k, v in chunk_gen.OUT.items()}
    for k, p in out.items():
        if not os.path.isfile(p):
            bad('phase 3: %s is missing (run chunk_gen.py)' % os.path.relpath(p, GORE))
            return
    # ---- current?
    tmp = tempfile.mkdtemp(prefix='rsqgo_chunklint_')
    try:
        gen, P, _, _ = chunk_gen.write_all(bd, xm, root=tmp)
        same_as_flat(gen, bad)
        for k, rel in chunk_gen.OUT.items():
            with open(os.path.join(tmp, rel), 'rb') as fa, open(out[k], 'rb') as fb:
                # line endings aside: git (core.autocrlf) checks text out with CRLF on Windows
                if fa.read().replace(b'\r\n', b'\n') != fb.read().replace(b'\r\n', b'\n'):
                    bad('phase 3: %s is stale (regenerate with chunk_gen.py)' % rel)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    # ---- the table
    rows = {}
    for ln in (read(os.path.join(GORE, 'generated', 'takeover_table.txt')) or '').split('\n'):
        if not ln or ln.startswith('#') or ln.startswith('class\t'):
            continue
        c = ln.split('\t')
        if len(c) >= 4:
            rows[c[0].lower()] = (c[1], c[3])
    zs = strip_c(read(out['zscript']))
    cls = classes_in(zs)
    gen_names = {n.lower(): (n, par, body) for n, par, body in cls}
    parents = {par.lower() for _, par, _ in cls}
    for n, par, body in cls:
        if n.startswith(chunk_gen.BASE_PREFIX):
            if re.search(r'\bDefault\s*\{', body):
                bad('phase 3: shared base %s has a Default (each class writes its own)' % n)
            if n.lower() not in parents:
                bad('phase 3: shared base %s is no class\'s parent' % n)
            continue
        bdname = n[len(chunk_gen.PREFIX):].lower()
        r = rows.get(bdname)
        if r is None:
            bad('phase 3: %s is not a class of the takeover table' % n)
        elif r[0] not in chunk_gen.PHASE3 or r[1] != 'gore':
            bad('phase 3: %s takes over a %s / %s class (only phase 3, Gore-owned)' % (n, r[0], r[1]))
    left = {p.name.lower() for p in gen.plans if p.left}
    for k, (catl, owner) in sorted(rows.items()):
        if catl in chunk_gen.PHASE3 and owner == 'gore' and (chunk_gen.PREFIX + k).lower() not in gen_names and k not in left:
            bad('phase 3: table class %s has no generated class and is not listed as left to BD' % k)
    # ---- per class
    fl_ok, fl_dep, fl_dummy = chunk_gen.engine_flags()
    labels_of = {}
    for n, par, body in cls:
        st = re.search(r'\bStates\s*\{(.*)\}\s*$', body, re.S)
        sb = st.group(1) if st else ''
        labs = [x.lower() for x in re.findall(r'^\s*([A-Za-z_][\w.]*)\s*:\s*$', sb, re.M)]
        seen = set()
        for lb in labs:
            if lb in seen:
                bad('phase 3: %s defines label %s twice' % (n, lb))
            seen.add(lb)
        labels_of[n.lower()] = (set(labs), par.lower())
    below = {}                  # a shared base -> the generated classes under it (not bases)
    for n, par, body in cls:
        if n.startswith(chunk_gen.BASE_PREFIX):
            continue
        c, depth = par.lower(), 0
        while c in labels_of and depth < 16:
            below.setdefault(c, []).append(n.lower())
            c = labels_of[c][1]
            depth += 1
    for n, par, body in cls:
        def has(lb, c=n.lower()):
            lb = lb.lower()
            if lb in ACTOR_BUILTIN:
                return True
            depth = 0
            while c in labels_of and depth < 32:
                s, pc = labels_of[c]
                if lb in s:
                    return True
                c = pc
                depth += 1
            return False
        st = re.search(r'\bStates\s*\{(.*)\}\s*$', body, re.S)
        sb = st.group(1) if st else ''
        for g in re.findall(r'\bgoto\s+([\w.]+)', sb):
            if not has(g):
                bad('phase 3: %s goes to %s, which it does not define' % (n, g))
        for call in re.finditer(r'\b(A_Jump|A_JumpIf|A_CheckFloor|A_CheckCeiling|A_CheckSight|A_JumpIfHealthLower|'
                                r'RSQGO_JumpIfLowGfx|RSQGO_JumpIfLiquid|RSQGO_JumpIfInv|RSQGO_Janitor3)\s*\(([^;]*)\)', sb):
            for lb in re.findall(r'"([^"]*)"', call.group(2)):
                # a quoted label resolves at run time in the actor's class: in a shared base, a class under it that
                # reaches this state (a class that never reaches it may lack the label; same_as_flat checks each one)
                if n.startswith(chunk_gen.BASE_PREFIX):
                    if not any(has(lb, d) for d in below.get(n.lower(), [])):
                        bad('phase 3: %s jumps to "%s", which no class under it defines' % (n, lb))
                elif not has(lb):
                    bad('phase 3: %s jumps to "%s", which it does not define' % (n, lb))
        dm = re.search(r'\bDefault\s*\{(.*?)\n\t\}', body, re.S)
        for sign, f in re.findall(r'^\s*([+-])(\w+);', dm.group(1) if dm else '', re.M):
            if f.upper() not in fl_ok:
                bad('phase 3: %s sets %s%s, which is not an engine flag' % (n, sign, f))
        go = re.search(r'RSQGO_Chunk\.GibOf\s+"(\w+)"', body)
        if go:
            c, up = par.lower(), []
            while c.startswith(chunk_gen.BASE_PREFIX.lower()) and c in labels_of:
                up.append(c)
                c = labels_of[c][1]
            if go.group(1).lower() != c:
                bad('phase 3: %s becomes %s but subclasses %s' % (n, go.group(1), ' : '.join(up + [c])))
        if 'RSQGO_DeathEntry' in body and not go:
            bad('phase 3: %s has a death dispatcher but is no flier' % n)
        # a BD class as a class constant (ZScript compiles before DECORATE): only names in single quotes may name one
        for m in re.finditer(r'\b(A_SpawnItem|A_SpawnItemEx|A_SpawnProjectile|A_GiveToTarget|A_GiveInventory|'
                             r'A_JumpIfInventory|A_CustomMissile)\s*\(\s*"', sb):
            bad('phase 3: %s calls %s with a class constant' % (n, m.group(1)))
    # ---- the runtime
    rt = strip_c(read(os.path.join(GORE, 'zscript', 'rsqgo', 'chunks.zs')) or '')
    if not rt:
        bad('phase 3: zscript/rsqgo/chunks.zs is missing')
    defined = set(re.findall(r'\b(RSQGO_\w+)\s*\(', rt))
    for used in sorted(set(re.findall(r'\b(RSQGO_(?!G_)\w+)\s*[(;]', zs)) - defined - {'RSQGO_Chunk', 'RSQGO_Limb', 'RSQGO_Casing'}):
        bad('phase 3: the generated states call %s, which chunks.zs does not define' % used)
    for base in ('RSQGO_Chunk', 'RSQGO_Limb', 'RSQGO_Casing', 'RSQGO_GibRing', 'RSQGO_Gibs'):
        if not re.search(r'^class\s+%s\b' % base, rt, re.M):
            bad('phase 3: chunks.zs does not define %s' % base)
    # ---- class names across Gore's ZScript
    decl = {}
    for d, _, fs in os.walk(os.path.join(GORE, 'zscript')):
        for f in fs:
            if f.lower().endswith(('.zs', '.zsc', '.txt')):
                t = strip_c(read(os.path.join(d, f)) or '')
                for c in re.findall(r'^\s*class\s+(\w+)', t, re.M | re.I):
                    decl.setdefault(c.lower(), []).append(f)
    for c, fs in sorted(decl.items()):
        if len(fs) > 1:
            bad('class %s is declared %d times (%s)' % (c, len(fs), ', '.join(sorted(fs))))
    # ---- MODELDEF
    md = strip_c(read(out['modeldef']) or '')
    for c in re.findall(r'^Model\s+(\w+)', md, re.M):
        if c.lower() not in gen_names:
            bad('phase 3: MODELDEF.chunks names %s, which is not a generated class' % c)
    # ---- the hooks (applied by hand to files other lanes own)
    hook = bad if strict else note
    inc = strip_c(read(os.path.join(GORE, 'zscript.txt')) or '')
    for f in ('zscript/rsqgo/chunks.zs', 'zscript/rsqgo/chunk_cards.zs'):
        if '"%s"' % f not in inc:
            hook('phase 3 hook: zscript.txt does not #include "%s"' % f)
    mg = strip_c(read(os.path.join(GORE, 'zscript', 'rsqgo', 'manager.zs')) or '')
    if not re.search(r'\bRSQGO_Gibs\s+gibs\s*;', mg):
        hook('phase 3 hook: RSQGO_Manager has no field `transient RSQGO_Gibs gibs;`')
    if 'RSQGO_Gibs.Lookup(' not in mg:
        hook('phase 3 hook: RSQGO_Manager.CheckReplacement does not call RSQGO_Gibs.Lookup')
    bs = read(os.path.join(GORE, 'build.sh')) or ''
    if 'MODELDEF.chunks' not in bs:
        hook('phase 3 hook: build.sh does not pack MODELDEF.chunks')


# ---------------------------------------------------------------- the shared bases change nothing
def parse_states(t):
    """class (lower) -> (parent, [state text], {label: ('idx', i) | ('goto', name) | ('stop',) | ('wait',)}, [next])"""
    cls = {}
    for m in re.finditer(r'^class\s+(\w+)\s*:\s*(\w+)\s*\{(.*?)^\}', t, re.M | re.S):
        n, par, body = m.group(1).lower(), m.group(2).lower(), m.group(3)
        sm = re.search(r'\tStates\n\t\{\n(.*?)\n\t\}', body, re.S)
        states, labels, pend, nexts = [], {}, [], []
        for ln in (sm.group(1).split('\n') if sm else []):
            s = ln.strip()
            if s.endswith(':'):
                pend.append(s[:-1].lower())
                continue
            g = re.match(r'^goto\s+([\w.]+);$', s)
            if g or s in ('stop;', 'wait;'):
                tgt = ('goto', g.group(1).lower()) if g else ('stop',) if s == 'stop;' else ('wait',)
                for x in pend:
                    labels[x] = tgt
                pend = []
                if states and nexts[-1] is None:
                    nexts[-1] = tgt
                continue
            for x in pend:
                labels[x] = ('idx', len(states))
            pend = []
            if states and nexts[-1] is None:
                nexts[-1] = ('idx', len(states))
            states.append(s)
            nexts.append(None)
        cls[n] = (par, states, labels, nexts)
    return cls


def machine(cls, leaf):
    """The states class `leaf` runs, as the engine resolves them, numbered from its labels: (labels, nodes)."""
    tabs = {}

    def table(c):
        if c not in tabs:
            t = dict(table(cls[c][0])) if c in cls and cls[c][0] in cls else {}
            if c in cls:
                for nm, v in cls[c][2].items():
                    t[nm] = (c, v)
            tabs[c] = t
        return tabs[c]

    def resolve(c, nm, depth=0):
        t = table(c)
        if nm not in t or depth > 20:
            return None
        d, v = t[nm]
        if v[0] == 'idx':
            return (d, v[1]) if v[1] < len(cls[d][1]) else 'stop'
        if v[0] == 'goto':
            return resolve(d, v[1], depth + 1)
        return v[0]
    ids, order = {}, []

    def nid(x):
        if not isinstance(x, tuple):
            return str(x)
        if x not in ids:
            ids[x] = 'N%d' % len(ids)
            order.append(x)
        return ids[x]
    labs = {n: nid(resolve(leaf, n)) for n in sorted(table(leaf)) if not GEN_LABEL.match(n)}
    nodes, i = {}, 0
    while i < len(order):
        d, k = order[i]
        i += 1

        def q(m):
            r = resolve(leaf, m.group(1).lower())      # a quoted label: the actor's class, at run time
            return m.group(0) if r is None else '<%s>' % nid(r)
        s = re.sub(r'"([\w.]+)"', q, cls[d][1][k])
        nx = cls[d][3][k]
        if nx is None:
            nxs = 'stop'
        elif nx[0] == 'idx':
            nxs = nid((d, nx[1]) if nx[1] < len(cls[d][1]) else 'stop')
        elif nx[0] == 'goto':
            nxs = nid(resolve(d, nx[1]))               # a goto: the class that wrote it
        else:
            nxs = nx[0]
        nodes[ids[(d, k)]] = (s, nxs)
    return labs, nodes


def same_as_flat(gen, bad):
    def text():
        L = []
        for b in gen.bases:
            L += gen.base_text(b)
        for p in gen.plans:
            if not p.left:
                L += gen.class_text(p)
        return parse_states('\n'.join(L))
    shared = text()
    keep = (gen.bases, {id(p): p.chainb for p in gen.plans})
    gen.bases = []
    for p in gen.plans:
        p.chainb = []
    gen.render()
    flat = text()
    gen.bases = keep[0]
    for p in gen.plans:
        p.chainb = keep[1][id(p)]
    gen.render()
    for p in gen.plans:
        if not p.left and machine(flat, p.zname.lower()) != machine(shared, p.zname.lower()):
            bad('phase 3: %s does not run the same states as its flattened form (shared bases)' % p.zname)


def main(argv):
    strict = '--strict' in argv
    args = [x for x in argv[1:] if x != '--strict']
    if len(args) != 2:
        print(__doc__.strip().split('\n\n')[1])
        return 2
    for p in args:
        if not os.path.isfile(p):
            print('chunk_lint: no such pk3: ' + p)
            return 2
    problems, notes = [], []
    check(args[0], args[1], problems.append, notes.append, strict=strict)
    for n in notes:
        print('note: ' + n)
    for p in problems:
        print('PROBLEM: ' + p)
    print('chunk_lint: %s (%d problem%s)' % ('FAIL' if problems else 'ok', len(problems), '' if len(problems) == 1 else 's'))
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
