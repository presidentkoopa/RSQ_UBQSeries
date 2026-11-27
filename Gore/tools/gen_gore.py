#!/usr/bin/env python3
"""gen_gore.py -- RSQ Gore's class takeover table, generated from Brutal Doom 22's and XMVE's own DECORATE.

    python -I Gore/tools/gen_gore.py <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>

Reads both pk3s directly (zipfile, read-only; never an extracted copy), BD first, XMVE second (load order). Writes:

    Gore/generated/takeover_table.txt    one row per class RSQ Gore will take over (or hand to RSQ Score), tab-separated
    Gore/generated/takeover_summary.txt  counts per category, what could not be categorised, and the checks of the
                                         design's claims against the data (design/GORE_SYSTEM_DESIGN.md)

WHICH CLASSES. The design's section 4 family list, as name rules (RULES below, first match wins), plus every
descendant of a matched class across both packs (inheritance resolved through BD and XMVE together). A descendant that
matches no rule takes its parent's category. EXCLUDED, even as descendants: what section 4 leaves to BD (burn, frozen,
executions, meat shields), corpses and dying monsters (Q6), and everything in BD's Dead.dec (corpses and map
decorations: its Gibs2 / SmallBloodPool2 replace map things, which a residue ring must never recycle). A hit blood
whose own or inherited states give HitHead / HitLeg or run Head_Shot is a head check, not a blood: it becomes a hitbox
helper (RSQ Score's, Q1).

COLUMNS. class, category, phase (section 7), owner (gore / score), parent, source (pk3:path), replaces, flags that
matter (NOBLOCKMAP NOINTERACTION MISSILE BOUNCE SHOOTABLE, inherited), the Spawn sequence's shape (stop@N tics, park@N
on a -1 frame, loop/Pt with +jumps when the loop body has a jump that may leave it), what the Spawn sequence spawns (Tx2@0
= twice at tic 0, Tx1/4t = once every 4 tics while looping), what its Death sequence spawns, and its Translation.
Timings follow the fall-through path only (an A_Jump is not taken); random(a,b) tics give a range.

Deterministic: rows sorted by category order then class name (case-insensitive). Never hand-edit the outputs.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import decorate  # noqa: E402

GORE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(GORE, 'generated')

CATEGORIES = [  # (id, label, phase, owner) in table order
    ('hitblood', 'hit blood', 1, 'gore'),
    ('flying', 'flying+trail', 1, 'gore'),
    ('mist', 'mist+jet', 1, 'gore'),
    ('liquid', 'liquid check', 1, 'gore'),
    ('floor', 'floor spot+pool', 2, 'gore'),
    ('ceiling', 'ceiling', 2, 'gore'),
    ('drip', 'drip', 2, 'gore'),
    ('smear', 'smear', 2, 'gore'),
    ('meat', 'meat+guts', 3, 'gore'),
    ('limb', 'limb', 3, 'gore'),
    ('casing', 'casing', 3, 'gore'),
    ('wall', 'wall', 4, 'gore'),
    ('deathgroup', 'death group', 4, 'gore'),
    ('hitbox', 'hitbox helper', 5, 'score'),
    ('other', 'other', '-', 'gore'),
]
CAT = {c[0]: c for c in CATEGORIES}
CAT_BY_LABEL = {c[1]: c for c in CATEGORIES}

# Left to BD (section 4 last row; Q6 corpses). Beats every rule below, and is inherited.
EXCLUDE = re.compile(r'burn|frozen|freez|execut|meatshield|shield$|^dead|brutalized|^dying|noguts|dyingguts|fatalized|'
                     r'fallingsplattered', re.I)
# ...and by FILE: BD's corpses and map decorations (Dead.dec: Q6, and its classes replace map things such as Gibs and
# SmallBloodPool), burn, frozen and executions; XMVE's counterparts.
EXCLUDE_FILES = ('bd:actors/gore/dead.dec', 'bd:actors/gore/burn.dec', 'bd:actors/gore/frozen.dec',
                 'bd:actors/gore/executions.dec', 'xmve:meburn.txt', 'xmve:frozenguys.txt', 'xmve:medyingguys.txt')

# Death-group launchers by FILE: everything BD defines in GoreGroups.dec (section 4: "GoreGroups.dec launchers").
DEATHGROUP_FILES = ('actors/gore/goregroups.dec',)

# (category, regex on the class name). First match wins. Section 4's families, spelled as BD and XMVE spell them.
RULES = [
    ('hitbox',     r'^headshottarget|^legtarget'),
    ('deathgroup', r'^rip|^(?!xdeath).+xdeath(green)?$|^muchblood|^morebloodsprays|^gibs?z(green|blue|alien)?$'),
    ('hitblood',   r'^brutal_blood$|^(green|blue|alien)_blood$|sawblood$|^bloodsplatterreplacer$|^brainblood$|blooddying$'),
    ('liquid',     r'waterbloodchecker|waterbloodspot'),
    ('ceiling',    r'ceilbloodlauncher|ceilbloodspot'),
    ('drip',       r'dripingblood|drippingblood|blooddriping|blooddripping|^driping|ceilblood\w*spawner'),
    ('floor',      r'bloodspot|splattered|bloodpool|footprint'),
    ('smear',      r'bootsmear'),
    ('wall',       r'wall\w*blood|wallpainter|bloodsplinter'),
    ('flying',     r'flyingblood|^bloodtrails$|^bloodtr\d|liquidblood|underblood'),
    ('mist',       r'bloodmist|arterialblood|supergore|ultragore'),
    ('meat',       r'^xdeath[1-6](?!\d)|^xdeathorgan|^organ|guts|^smearing|^ceilxdeath|brainpiece|^xdeathbrain|eyeball|^teeth|^xjunk|'
                   r'^xdeathskinpiece|^xdeath\w*new\d'),
    ('casing',     r'^emptybrass$'),
    ('limb',       r'^xdeath|^gib|gibbase$|limbbase$|^tinygib$|gib\d*$|headpiece|^spiderleg$|^brains\d'),
]
RULES = [(c, re.compile(r, re.I)) for c, r in RULES]
# Helpers that INHERIT a gore class but are not gore (a camera shake, a sound player): category "other", listed in the
# summary for review. Checked on descendants only, so it never pulls an unrelated class into the table.
OTHER_RULE = re.compile(r'^goresound$|shake', re.I)
HEADLOGIC = re.compile(r'\bHitHead\b|\bHitLeg\b|Head_Shot', re.I)
HELPER_NAME = re.compile(r'^(headshottarget\d+b?|legtarget\w*)$', re.I)
# Names the design cites, checked for existence (design/GORE_SYSTEM_DESIGN.md sections 1-5).
DESIGN_NAMES = ('Brutal_Blood', 'Green_Blood', 'Blue_Blood', 'Alien_Blood', 'SawBlood', 'BloodSPlatterReplacer', 'BrainBlood',
                'BloodDying', 'BloodTrails', 'ArterialBloodSpray', 'WaterBloodCHecker', 'WaterBloodSpot', 'GrowingBloodPool',
                'Organs', 'Guts', 'GibEyeball', 'TinyGib', 'LimbBase', 'BigGibBase', 'EmptyBrass', 'WallRedBlood',
                'RedBloodCircularWallPainter', 'BloodSplinter', 'HeadshotTargetBase', 'LegTargetBase', 'LegTarget4b',
                'DarkImpXDeath', 'ChainMajorXDeath', 'ZSpecOpsXDeath', 'BloodSplasher_Red', 'BootSmearerRed',
                'Brutal_FlyingBloodTrail', 'Brutal_LiquidBloodTrail', 'SuperGoreMistTiny', 'Brutal_BloodSpot',
                'BloodDripingFromCeiling', 'DripingBloodLeavesSmallPool', 'Brutal_FlyingBloodFaster', 'SuperGore',
                'CeilBloodTinyBloodSpawner', 'ArterialBlood22Small', 'BloodMist22Small', 'GreenBloodMist', 'GreenBloodMistBig',
                'ZombieXDeath', 'HeadshotTarget4', 'HeadshotTarget10', 'LegTarget4', 'LegTarget12', 'HitHead', 'HitLeg',
                'BootsSmearedWithRedBlood', 'SlaughterCounter')
# Timings the design states, set beside the data (fall-through path).
DESIGN_TIMINGS = (('CeilBloodSpot', '"thrusts every 5 tics forever"'), ('CeilBloodTinyBloodSpawner', '"~800 tics, 56 drip spawns"'),
                  ('BootSmearerRed', '"880 tics"'), ('EmptyBrass', '"210 tics"'), ('ZombieXDeath', '"54 direct spawns"'),
                  ('LimbBase', '"a spot every 1,900 tics"'), ('HeadshotTarget4', '"6 tics"'), ('HeadshotTarget10', '"13 tics"'),
                  ('GrowingBloodPool', '"a 70-tic scale ramp"'))
SCORE_SET_FILE = os.path.join(os.path.dirname(GORE), 'Score', 'zscript', 'rsscore', 'head.zs')
FLAG_COLS = ('noblockmap', 'nointeraction', 'missile', 'bounce', 'shootable')


# ------------------------------------------------------------------ walking a state sequence
def fmt_t(t):
    return str(t[0]) if t[0] == t[1] else '%d-%d' % t


def walk(world, key, label, limit=5000):
    """Follow `label` for class `key` along fall-through. Returns dict(shape, once, periodic, jumps)."""
    res = {'shape': 'none', 'once': [], 'periodic': [], 'jumps': False}
    r = world.find_label(key, label)
    if r is None:
        return res
    definer, ref = r
    loc = None
    flow = None
    if ref[0] == 'idx':
        loc = (definer, ref[1])
    else:
        flow = (definer, ref[1])
    t = (0, 0)
    visited, seq = {}, []
    for _ in range(limit):
        if flow is not None:                          # a label that is only a flow keyword
            d, f = flow
            flow = None
            if f[0] in ('stop', 'fail'):
                res['shape'] = 'stop@' + fmt_t(t); break
            if f[0] == 'goto':
                g = world.goto(d, f[1])
                if g is None:
                    res['shape'] = 'unresolved:goto ' + f[1]; break
                if g[0] == 'flow':
                    flow = (g[1], g[2]); continue
                loc = g
            elif f[0] == 'loop':
                loc = (d, f[1])
            else:
                res['shape'] = 'stop@' + fmt_t(t); break
        st = world.cls[loc[0]].states
        if loc[1] >= len(st.S):
            res['shape'] = 'stop@' + fmt_t(t); break
        if loc in visited:
            vt, vstep = visited[loc]
            period = (t[0] - vt[0], t[1] - vt[1])
            body = seq[vstep:]
            jumps = any(j for _, _, _, j in body)
            for _, _, sp, _ in body:
                res['periodic'] += sp
            for _, _, sp, _ in seq[:vstep]:
                res['once'] += [(x, tt) for x, tt in sp]
            res['shape'] = 'loop/%st%s%s' % (fmt_t(period), '!' if period == (0, 0) else '', '+jumps' if jumps else '')
            res['period'] = period
            seq = None
            break
        visited[loc] = (t, len(seq))
        s = st.S[loc[1]]
        sp = [(m.group(2), t) for m in decorate.SPAWN_RE.finditer(s['action'])]
        jmp = bool(decorate.JUMP_RE.search(s['action']))
        res['jumps'] |= jmp
        seq.append((loc, t, sp, jmp))
        if s['tics'][0] < 0:
            res['shape'] = 'park@' + fmt_t(t); break
        t = (t[0] + s['tics'][0], t[1] + s['tics'][1])
        nx = st.nxt[loc[1]]
        if nx[0] == 'seq':
            loc = (loc[0], loc[1] + 1)
        elif nx[0] in ('stop', 'fail'):
            res['shape'] = 'stop@' + fmt_t(t); break
        elif nx[0] == 'wait':
            pass                                      # same state again: the loop check catches it
        elif nx[0] == 'loop':
            loc = (loc[0], nx[1])
        elif nx[0] == 'goto':
            g = world.goto(loc[0], nx[1])
            if g is None:
                res['shape'] = 'unresolved:goto ' + nx[1]; break
            if g[0] == 'flow':
                flow = (g[1], g[2]); loc = None
            else:
                loc = g
    else:
        res['shape'] = 'too long'
    if seq is not None:
        for _, _, sp, _ in seq:
            res['once'] += sp
    return res


def fmt_spawns(res, world):
    out, agg, order = [], {}, []
    for name, tt in res['once']:
        k = ('o', name.lower())
        if k not in agg:
            agg[k] = [name, 0, tt]; order.append(k)
        agg[k][1] += 1
    per = res.get('period', (0, 0))
    for name, tt in res['periodic']:
        k = ('p', name.lower())
        if k not in agg:
            agg[k] = [name, 0, tt]; order.append(k)
        agg[k][1] += 1
    for k in order:
        name, cnt, tt = agg[k]
        spelled = world.cls[name.lower()].name if name.lower() in world.cls else name + '?'
        if k[0] == 'o':
            out.append('%sx%d@%s' % (spelled, cnt, fmt_t(tt)))
        else:
            out.append('%sx%d/%st' % (spelled, cnt, fmt_t(per)))
    return ', '.join(out) if out else '-'


# ------------------------------------------------------------------ categorising
class Cat:
    def __init__(self, world):
        self.w = world
        self.memo = {}
        self.why = {}

    def rule(self, key):
        a = self.w.cls[key]
        if EXCLUDE.search(a.name):
            return 'exclude', 'excluded name'
        if a.source.lower() in EXCLUDE_FILES:
            return 'exclude', 'excluded file'
        src = a.source.split(':', 1)[1].lower()
        if a.source.startswith('BD:') and src in DEATHGROUP_FILES:
            return 'deathgroup', 'file GoreGroups.dec'
        for c, rx in RULES:
            if rx.search(a.name):
                return c, 'name /%s/' % rx.pattern
        return None, None

    def get(self, key, depth=0):
        if key in self.memo:
            return self.memo[key]
        self.memo[key] = None                         # cycle guard
        c, why = self.rule(key)
        if c is None:
            p = self.w.cls[key].pkey
            if p and p in self.w.cls and depth < 64:
                pc = self.get(p, depth + 1)
                if pc and pc != 'exclude' and OTHER_RULE.search(self.w.cls[key].name):
                    c, why = 'other', 'inherits %s, but name /%s/' % (self.w.cls[p].name, OTHER_RULE.pattern)
                elif pc and pc != 'exclude':
                    c, why = pc, 'inherits ' + self.w.cls[p].name
                elif pc == 'exclude':
                    c, why = 'exclude', 'inherits excluded ' + self.w.cls[p].name
        if c == 'hitblood' and self.head_logic(key):
            c, why = 'hitbox', 'hit blood with HitHead/HitLeg/Head_Shot in its states'
        self.memo[key] = c
        self.why[key] = why
        return c

    def head_logic(self, key):
        for k in self.w.chain(key):
            st = self.w.cls[k].states
            if st and any(HEADLOGIC.search(s['action']) for s in st.S):
                return True
        return False


def score_set():
    """RSQ Score's exact-name takeovers (head.zs FROM[]), read-only; empty if Score is not beside us."""
    try:
        t = open(SCORE_SET_FILE, encoding='utf-8', errors='replace').read()
    except OSError:
        return set()
    m = re.search(r'static\s+const\s+String\s+FROM\s*\[\s*\]\s*=\s*\{(.*?)\}', t, re.S)
    return {x.lower() for x in re.findall(r'"([^"]+)"', m.group(1))} if m else set()


# ------------------------------------------------------------------ main
def build(bd, xm):
    world = decorate.World([(bd, 'BD'), (xm, 'XMVE')])
    cat = Cat(world)
    rows = []
    for key in world.order:
        c = cat.get(key)
        if c in (None, 'exclude'):
            continue
        a = world.cls[key]
        fl = world.flags(key)
        bounce = fl.get('_bounce', False) or any(fl.get(f) for f in decorate.BOUNCE_FLAGS)
        flags = []
        for f in FLAG_COLS:
            on = bounce if f == 'bounce' else fl.get(f, False)
            if on:
                flags.append(f.upper())
        sp = walk(world, key, 'Spawn')
        dth = walk(world, key, 'Death')
        parent = a.parent if a.parent else '-'
        if a.pkey and a.pkey not in world.cls:
            parent += ' (engine)'
        tr = world.prop(key, 'translation') or '-'
        rows.append({
            'class': a.name, 'cat': c, 'label': CAT[c][1], 'phase': str(CAT[c][2]), 'owner': CAT[c][3],
            'parent': parent, 'source': a.source, 'replaces': a.replaces or '-',
            'flags': ' '.join(flags) or '-', 'shape': sp['shape'], 'spawns': fmt_spawns(sp, world),
            'death': fmt_spawns(dth, world) if dth['shape'] != 'none' else '-', 'translation': tr,
            'why': cat.why.get(key) or '-', 'key': key,
        })
    order = {c[0]: i for i, c in enumerate(CATEGORIES)}
    rows.sort(key=lambda r: (order[r['cat']], r['class'].lower()))
    return world, cat, rows


COLS = ('class', 'label', 'phase', 'owner', 'parent', 'source', 'replaces', 'flags', 'shape', 'spawns', 'death',
        'translation', 'why')
HEAD = ('class', 'category', 'phase', 'owner', 'parent', 'source', 'replaces', 'flags', 'spawn_shape', 'spawn_spawns',
        'death_spawns', 'translation', 'why')


def write_table(rows, bd, xm):
    p = os.path.join(OUT, 'takeover_table.txt')
    with open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write('# RSQ Gore takeover table -- GENERATED by Gore/tools/gen_gore.py from %s and %s. Never hand-edit.\n'
                % (os.path.basename(bd), os.path.basename(xm)))
        f.write('# One row per class, tab-separated. Design: design/GORE_SYSTEM_DESIGN.md sections 2.3, 4, 7.\n')
        f.write('# spawn_shape: stop@N = ends after N tics; park@N = sits on a -1 frame from tic N; loop/Pt = repeats every P\n')
        f.write('#   tics (! = zero-tic loop; +jumps = a jump in the loop may leave it). Fall-through path only.\n')
        f.write('# spawn_spawns / death_spawns: Name xK@T = K spawns at tic T; Name xK/Pt = K spawns every P tics.\n')
        f.write('\t'.join(HEAD) + '\n')
        for r in rows:
            f.write('\t'.join(r[c].replace('\t', ' ') for c in COLS) + '\n')
    return p


def write_summary(world, cat, rows, bd, xm):
    L = []
    w = L.append
    w('RSQ Gore takeover summary -- GENERATED by Gore/tools/gen_gore.py. Never hand-edit.')
    w('Packs: BD = %s, XMVE = %s' % (os.path.basename(bd), os.path.basename(xm)))
    w('DECORATE files parsed: BD %d, XMVE %d. Classes read: %d (BD %d, XMVE %d).' % (
        len(world.files['BD']), len(world.files['XMVE']), len(world.cls),
        sum(1 for k in world.order if world.cls[k].source.startswith('BD:')),
        sum(1 for k in world.order if world.cls[k].source.startswith('XMVE:'))))
    w('')
    w('== Classes per category (BD + XMVE = total)')
    tot = 0
    for c in CATEGORIES:
        rs = [r for r in rows if r['cat'] == c[0]]
        nb = sum(1 for r in rs if r['source'].startswith('BD:'))
        w('  %-16s phase %-2s %-6s %4d + %3d = %4d' % (c[1], c[2], c[3], nb, len(rs) - nb, len(rs)))
        tot += len(rs)
    w('  %-16s %21s = %4d' % ('TOTAL', '', tot))
    w('')
    other = [r for r in rows if r['cat'] == 'other']
    w('== Not categorised (category "other"): %d' % len(other))
    for r in other:
        w('  %s  (%s; %s; %s)' % (r['class'], r['source'], r['why'], r['shape']))
    w('')

    # ---- gore-file classes left out of the table
    gore_files = [('BD', 'actors/gore/'), ('XMVE', 'gore.txt')]
    w('== Classes in the gore files that the table leaves to BD (by file)')
    intable = {r['key'] for r in rows}
    byfile = {}
    for k in world.order:
        a = world.cls[k]
        pk, path = a.source.split(':', 1)
        for gp, gf in gore_files:
            if pk == gp and path.lower().startswith(gf):
                if k not in intable:
                    byfile.setdefault(path, []).append(a.name + (' [excluded]' if cat.memo.get(k) == 'exclude' else ''))
    for path in sorted(byfile, key=str.lower):
        names = byfile[path]
        w('  %s (%d): %s' % (path, len(names), ', '.join(sorted(names, key=str.lower))))
    w('')

    # ---- facts for the design
    w('== Checks of the design against the data')
    nbd = sum(1 for k in world.order if world.cls[k].source.lower().startswith('bd:actors/gore/'))
    nxm = sum(1 for k in world.order if world.cls[k].source.lower() == 'xmve:gore.txt')
    w('  Gore-file class counts (design section 4 says BD 867, XMVE 122): BD actors/Gore/ %d, XMVE Gore.txt %d' % (nbd, nxm))
    for name in ('HeadshotTarget4', 'HeadshotTarget6', 'HeadshotTarget10', 'HeadshotTarget20', 'LegTargetBase',
                 'LegTarget4', 'LegTarget12', 'LegTarget4b'):
        k = name.lower()
        if k not in world.cls:
            w('  %s: NOT DEFINED in either pack' % name)
            continue
        sp = walk(world, k, 'Spawn')
        w('  %s: radius %s height %s, Spawn %s (%s)' % (name, world.prop(k, 'radius'), world.prop(k, 'height'),
                                                       sp['shape'], world.cls[k].source))
    for root in ('headshottargetbase', 'legtargetbase'):
        if root in world.cls:
            d = sorted((world.cls[x].name for x in world.descendants(root) if not HELPER_NAME.match(world.cls[x].name)),
                       key=str.lower)
            w('  `is %s` also catches %d classes that are not per-frame helpers: %s' % (
                world.cls[root].name, len(d), ', '.join(d) or '-'))
    pairs = [('GreenBloodMist', 'BloodMist'), ('GreenBloodMistBig', 'BloodMistBig'), ('Green_Blood', 'Brutal_Blood'),
             ('Bloodmist', 'Brutal_FlyingBlood'), ('CeilBloodLauncher', 'Brutal_FlyingBlood'),
             ('CeilXDeath2', 'Brutal_BloodSpot')]
    for a, b in pairs:
        if a.lower() in world.cls:
            w('  %s : %s (design 4 colour-root claim check: parent is %s)' % (a, b, world.cls[a.lower()].parent))
    w('  Classes the design names (missing ones are listed): %s' % (
        ', '.join(n for n in DESIGN_NAMES if n.lower() not in world.cls) or 'all present'))
    for name, claim in DESIGN_TIMINGS:
        k = name.lower()
        if k in world.cls:
            sp = walk(world, k, 'Spawn')
            w('  %s: design says %s; Spawn (fall-through) %s; spawns %s' % (name, claim, sp['shape'], fmt_spawns(sp, world)))
    ss = score_set()
    extra = sorted(r['class'] for r in rows if r['cat'] == 'hitbox' and r['key'] not in ss
                   and not HELPER_NAME.match(r['class']) and cat.head_logic(r['key']))
    w('  Head-check bloods NOT in RSQ Score\'s set (an `is SawBlood` / `is Brutal_Blood` fallback would take them as hit '
      'blood and lose their HitHead/HitLeg): %s' % (', '.join(extra) or 'none'))
    clash = sorted(r['class'] for r in rows if r['key'] in ss and r['owner'] != 'score')
    inscore = sorted(r['class'] for r in rows if r['key'] in ss)
    w('  RSQ Score exact-name set (Score/zscript/rsscore/head.zs FROM[]): %d names; in this table as Score-owned: %s; '
      'Gore-owned clashes: %s' % (len(ss), ', '.join(inscore) or '-', ', '.join(clash) or 'none'))
    w('')

    w('== Table classes that replace something, or are replaced by another class')
    repl_by = {}
    for k in world.order:
        a = world.cls[k]
        if a.replaces:
            repl_by.setdefault(a.replaces.lower(), []).append(a.name)
    for r in rows:
        if r['replaces'] != '-':
            w('  %s replaces %s' % (r['class'], r['replaces']))
        if r['key'] in repl_by:
            w('  %s is REPLACED by %s' % (r['class'], ', '.join(repl_by[r['key']])))
    w('')
    w('== Duplicate definitions (the engine keeps the first; later ones are renamed Name@file)')
    for name, first, later in world.dups:
        if name.lower() in intable:
            w('  %s: kept %s, renamed %s' % (name, first, later))
    other_dups = sum(1 for name, _, _ in world.dups if name.lower() not in intable)
    w('  (%d more duplicates outside the table)' % other_dups)
    w('')
    w('== Parse warnings')
    for pk, inc, frm in world.missing:
        w('  %s: #include "%s" in %s not found' % (pk, inc, frm))
    unres = [r for r in rows if r['shape'].startswith('unresolved') or r['shape'] == 'too long']
    for r in unres:
        w('  %s: Spawn %s' % (r['class'], r['shape']))
    zero = [r['class'] for r in rows if '!' in r['shape']]
    w('  zero-tic Spawn loops: %s' % (', '.join(zero) or 'none'))
    nospawn = [r['class'] for r in rows if r['shape'] == 'none']
    w('  no DECORATE Spawn state (engine parent\'s states): %s' % (', '.join(nospawn) or 'none'))
    p = os.path.join(OUT, 'takeover_summary.txt')
    with open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(L) + '\n')
    return p, L


def main(argv):
    if len(argv) != 3:
        print(__doc__.strip().split('\n\n')[1])
        return 2
    bd, xm = argv[1], argv[2]
    for p in (bd, xm):
        if not os.path.isfile(p):
            print('gen_gore: no such pk3: ' + p)
            return 2
    os.makedirs(OUT, exist_ok=True)
    world, cat, rows = build(bd, xm)
    t = write_table(rows, bd, xm)
    s, lines = write_summary(world, cat, rows, bd, xm)
    print('wrote %s (%d rows)' % (t, len(rows)))
    print('wrote %s' % s)
    end = next((i for i, x in enumerate(lines) if x.startswith('== Not categorised')), len(lines))
    print('\n'.join(lines[:end + 1 + sum(1 for r in rows if r['cat'] == 'other')]))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
