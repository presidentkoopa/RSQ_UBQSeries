#!/usr/bin/env python3
"""death_lint.py -- RSQ Gore phase 4's lint (death_gen.py's outputs and deaths.zs). Exits 1 on any problem, 0 clean.

    python -I Gore/tools/death_lint.py <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>

Also callable from gore_lint.py: death_lint.check(bd, xm, bad, note, strict=True).

  - the outputs are current: death_gen.py run now into a temporary folder gives zscript/rsqgo/death_cards.zs and
    generated/death_summary.txt byte for byte (they also depend on the takeover table and the phase 1-3 cards);
  - every RSQGO_D_ / RSQGO_W_ class is a "death group" or "wall", Gore-owned row of the takeover table, and every such
    row has a class or is listed under "Left to BD" with its reason;
  - per recipe: entry ranges in bounds, a wall / recipe reference that exists, an inline painter's entries all wall
    traces on its first tic, every class an entry spawns exists in BD or XMVE (or is an engine class BD replaces),
    every entry inside its group's end tic, an argument string of 9 numbers or ranges;
  - deaths.zs: never consoleplayer, no user cvar read, every rsqgo_ name declared in CVARINFO.txt, no `out Vector`;
    every RSQGO_Deaths method the generated file calls is defined; every member of the other phases it uses still
    exists (RSQGO_Manager.Process / Fly / flyHit ..., RSQGO_ResidueRings.Launch, RSQGO_GibRing.FlyCap, ...);
  - no class name declared twice across Gore's ZScript (case-insensitive);
  - THE HOOKS (zscript.txt includes, CheckReplacement's RSQGO_Deaths.Lookup call, DebugLine's DebugText): notes when
    run alone (they are applied by hand), problems when strict (from gore_lint.py).
"""
import os
import re
import shutil
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import decorate  # noqa: E402
import death_gen  # noqa: E402

GORE = death_gen.GORE
ZS = os.path.join(GORE, 'zscript', 'rsqgo')
ENGINE_REPLACED = {'blood'}     # engine classes BD replaces by DECORATE (Brutal_Blood replaces Blood)

# (file, regex) that must still match: what deaths.zs uses from the other phases
USES = [
    ('emit.zs', r'void\s+Process\s*\(\s*int\s+c\s*,\s*Actor\s+src\s*,\s*Vector3\s+p0\s*,\s*Vector3\s+v0\s*,\s*double\s+ang\s*,'
                r'\s*int\s+delay\s*,\s*int\s+depth\s*,\s*bool\s+uw'),
    ('emit.zs', r'Line\s+Fly\s*\(\s*Actor\s+src\s*,\s*Vector3\s+p0\s*,\s*Vector3\s+v0\s*,\s*double\s+g\s*,\s*int\s+life'),
    ('emit.zs', r'enum\s+EHit\s*\{[^}]*HIT_WALL'),
    ('manager.zs', r'transient\s+int\s+flyHit'),
    ('manager.zs', r'transient\s+Vector3\s+flyPos\s*,\s*flyDir'),
    ('manager.zs', r'transient\s+RSQGO_Data\s+data\s*;'),
    ('manager.zs', r'transient\s+RSQGO_ResidueRings\s+res\s*;'),
    ('manager.zs', r'bool\s+Ready\s*\(\s*\)'),
    ('manager.zs', r'static\s+RSQGO_Manager\s+Get\s*\(\s*\)'),
    ('data.zs', r'Map\s*<\s*Name\s*,\s*int\s*>\s*byName'),
    ('data.zs', r'Array\s*<\s*double\s*>\s*cSpeed'),
    ('data.zs', r'Array\s*<\s*int\s*>\s*cKind'),
    ('data.zs', r'enum\s+EKind\s*\{[^}]*K_HIT'),
    ('residue.zs', r'void\s+Launch\s*\(\s*Actor\s+a\s*,\s*int\s+c\s*\)'),
    ('residue.zs', r'static\s+RSQGO_ResidueRings\s+Get\s*\(\s*bool\s+create\s*\)'),
    ('residue.zs', r'transient\s+RSQGO_ResData\s+data\s*;'),
    ('residue.zs', r'bool\s+Ready\s*\(\s*\)'),
    ('residue_data.zs', r'Map\s*<\s*Name\s*,\s*int\s*>\s*byName'),
    ('residue_data.zs', r'Array\s*<\s*double\s*>\s*cSpeed'),
    ('residue_data.zs', r'enum\s+ERKind\s*\{[^}]*RK_LAUNCH'),
    ('chunks.zs', r'static\s+RSQGO_GibRing\s+Find\s*\(\s*bool\s+create\s*\)'),
    ('chunks.zs', r'int\s+FlyCap\s*\(\s*\)'),
    ('chunks.zs', r'\bint\s+flying\s*;'),
]


def read(p):
    try:
        return open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        return None


def strip_c(t):
    t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
    return re.sub(r'//[^\n]*', '', t)


def check(bd, xm, bad, note, strict=False):
    # ---- current
    tmp = tempfile.mkdtemp(prefix='rsqgo_death_')
    try:
        g, P = death_gen.write_all(bd, xm, root=tmp)
        for k, rel in death_gen.OUT.items():
            a, b = read(os.path.join(GORE, rel)), read(P[k])
            if a is None:
                bad('%s is missing (run Gore/tools/death_gen.py)' % rel)
            elif a != b:
                bad('%s is stale (run Gore/tools/death_gen.py)' % rel)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    # ---- classes vs the table
    cards = read(os.path.join(ZS, 'death_cards.zs')) or ''
    ours = re.findall(r'^class\s+RSQGO_([DW])_(\w+)\s*:\s*(\w+)', cards, re.M)
    rows = g.rows
    have = set()
    for kind, n, parent in ours:
        r = rows.get(n.lower())
        have.add(n.lower())
        if not r:
            bad('death_cards.zs: RSQGO_%s_%s is not a takeover table class' % (kind, n))
            continue
        if r['owner'] != 'gore' or r['cat'] not in ('death group', 'wall'):
            bad('death_cards.zs: RSQGO_%s_%s takes over a %s (%s) class' % (kind, n, r['cat'], r['owner']))
        want = 'RSQGO_WallRun' if kind == 'W' else 'RSQGO_DeathRun'
        if parent != want:
            bad('death_cards.zs: RSQGO_%s_%s derives from %s, not %s' % (kind, n, parent, want))
    left = {n.lower() for n, _ in g.left}
    for k, r in rows.items():
        if r['cat'] in ('death group', 'wall') and r['owner'] == 'gore' and k not in have and k not in left:
            bad('takeover table %s (%s) has no phase 4 class and is not listed as left to BD' % (r['name'], r['cat']))
    summ = read(os.path.join(GORE, 'generated', 'death_summary.txt')) or ''
    for n, _ in g.left:
        if ('  %s: ' % n) not in summ:
            bad('death_summary.txt does not list %s under "Left to BD"' % n)

    # ---- recipes
    known = set(g.world.cls) | ENGINE_REPLACED
    nw, nr = len(g.walls), len(g.recipes)
    missing = set()
    for r in g.recipes:
        ends = r['ends']
        for e in r['out']:
            where = '%s t%d %s' % (r['name'], e['t'], e['cls'] or death_gen.DR[e['route']])
            if len(e['args']) != death_gen.NARG:
                bad('recipe %s: %d arguments' % (where, len(e['args'])))
            if e['route'] == death_gen.R_WALL and not 0 <= e['ref'] < nw:
                bad('recipe %s: wall card %d out of range' % (where, e['ref']))
            if e['route'] == death_gen.R_RECIPE:
                if not 0 <= e['ref'] < nr:
                    bad('recipe %s: recipe %d out of range' % (where, e['ref']))
                elif not g.recipes[e['ref']]['inline']:
                    bad('recipe %s: routed inline to a recipe that is not an inline painter' % where)
            if e['route'] not in (death_gen.R_SOUND, death_gen.R_FACE) and e['cls'].lower() not in known:
                # BD's own call names a class nobody defines (XMVE RipHelltrooper's Instestin2): the engine spawns
                # nothing, and the recipe (a null class) spawns nothing either
                missing.add('%s in %s' % (e['cls'], r['name']))
            end = ends.get(e['g'])
            if end is None or e['t'] > end:
                bad('recipe %s: entry after its group\'s end tic (%s)' % (where, end))
        if r['inline']:
            for e in r['out']:
                if e['t'] != 0 or e['route'] != death_gen.R_WALL:
                    bad('inline painter %s: entry %s is not a first-tic wall trace' % (r['name'], e['cls']))
    for x in sorted(missing):
        note('BD\'s data spawns an undefined class (nothing spawns, in BD or here): %s' % x)
    for m in re.finditer(r'\bE\((\d+), (\d+), (\d+), (\d+), (-?\d+), "[^"]*", "[^"]*", "([^"]*)"\);', cards):
        toks = m.group(6).split()
        if len(toks) != death_gen.NARG or not all(re.match(r'^(?:[rf]-?[\d.]+:-?[\d.]+|-?[\d.]+)$', t) for t in toks):
            bad('death_cards.zs: bad argument string "%s"' % m.group(6))

    # ---- deaths.zs
    dz = read(os.path.join(ZS, 'deaths.zs'))
    if dz is None:
        bad('zscript/rsqgo/deaths.zs is missing')
        dz = ''
    code = strip_c(dz)
    code_ns = re.sub(r'"(?:[^"\\]|\\.)*"', '""', code)
    if re.search(r'\bconsoleplayer\b', code_ns):
        bad('deaths.zs reads consoleplayer (a recipe decides actors: never the console player)')
    if re.search(r'\bCVar\s*\.\s*GetCVar\b', code_ns):
        bad('deaths.zs reads a user cvar (recipes use server cvars only)')
    if re.search(r'\bout\s+Vector[23]\b', code_ns):
        bad('deaths.zs: an `out Vector` parameter (it compiles, then aborts the VM)')
    cv = set(x.lower() for x in re.findall(r'\b(rsqgo_\w+)\s*=', read(os.path.join(GORE, 'CVARINFO.txt')) or ''))
    for n in sorted(set(x.lower() for x in re.findall(r'\b(rsqgo_\w+)', code_ns))):
        if n not in cv:
            bad('deaths.zs uses %s, which CVARINFO.txt does not declare' % n)
    for meth in sorted(set(re.findall(r'^\t\t(\w+)\(', cards, re.M))):
        if not re.search(r'\bvoid\s+%s\s*\(' % meth, code):
            bad('death_cards.zs calls %s, which deaths.zs does not define' % meth)
    for f, rx in USES:
        t = strip_c(read(os.path.join(ZS, f)) or '')
        if not re.search(rx, t):
            bad('deaths.zs relies on %s matching /%s/, which is gone' % (f, rx[:60]))

    # ---- class names unique across Gore's ZScript
    seen = {}
    for d, _, fs in os.walk(os.path.join(GORE, 'zscript')):
        for fn in sorted(fs):
            if fn.lower().endswith('.zs'):
                for m in re.finditer(r'^\s*class\s+(\w+)', strip_c(read(os.path.join(d, fn)) or ''), re.M):
                    seen.setdefault(m.group(1).lower(), []).append(fn)
    for k, fl in sorted(seen.items()):
        if len(fl) > 1:
            bad('class %s is declared %d times (%s)' % (k, len(fl), ', '.join(fl)))

    # ---- hooks
    hook = bad if strict else note
    zt = strip_c(read(os.path.join(GORE, 'zscript.txt')) or '')
    for inc in ('zscript/rsqgo/deaths.zs', 'zscript/rsqgo/death_cards.zs'):
        if not re.search(r'#include\s+"%s"' % re.escape(inc), zt, re.I):
            hook('hook: zscript.txt does not include %s' % inc)
    mz = strip_c(read(os.path.join(ZS, 'manager.zs')) or '')
    m = re.search(r'override\s+void\s+CheckReplacement\b.*?\n\t\}', mz, re.S)
    if not m or 'RSQGO_Deaths.Lookup' not in m.group(0):
        hook('hook: RSQGO_Manager.CheckReplacement does not call RSQGO_Deaths.Lookup')
    if 'RSQGO_Deaths.DebugText' not in mz:
        note('hook (optional): RSQGO_Manager.DebugLine does not print RSQGO_Deaths.DebugText')
    return g


def main(argv):
    if len(argv) != 3:
        print(__doc__.strip().split('\n\n')[1])
        return 2
    for p in argv[1:]:
        if not os.path.isfile(p):
            print('death_lint: no such pk3: ' + p)
            return 2
    problems, notes = [], []
    check(argv[1], argv[2], problems.append, notes.append, strict=False)
    for n in notes:
        print('note: ' + n)
    for p in problems:
        print('PROBLEM: ' + p)
    print('death_lint: %s (%d problem%s)' % ('FAIL' if problems else 'ok', len(problems), '' if len(problems) == 1 else 's'))
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
