#!/usr/bin/env python3
"""gore_lint.py -- RSQ Gore's lint. Exits 1 on any problem, 0 when clean.

    python -I Gore/tools/gore_lint.py <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>

THE TAKEOVER TABLE (Gore/generated/takeover_table.txt) against both pk3s, read straight from the zips (read-only):
  - the file parses: the header, 13 columns a row, a known category with its phase and owner;
  - every class still exists in BD or XMVE (case-insensitive);
  - no class is claimed twice: no repeated row, and no Gore-owned class in RSQ Score's exact-name takeover set
    (Score/zscript/rsscore/head.zs FROM[], read-only; design section 3: the two handlers' sets are disjoint);
  - no category gaps: every descendant of a table class is in the table or deliberately excluded; "other" rows are
    listed (helpers inheriting a gore class), not failed;
  - the table is current: gen_gore.py run now on these pk3s gives the same rows and categories (else: regenerate).
GORE'S OWN FILES:
  - CVARINFO parses, every cvar is rsqgo_-prefixed and declared once, and the design's cvars are there with the scope
    and default the owner's answers set (REQUIRED below), the master switch off until the phases ship;
  - MENUDEF (phase 1 adds it): every cvar a row names exists, every non-noarchive cvar has a row, the front page's one
    sub menu is "Test and Debug" (design/MENU_STANDARD.md);
  - every rsqgo_ name the ZScript uses is declared; MAPINFO's handlers are ZScript classes; build.sh's include list exists.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import decorate  # noqa: E402
import gen_gore  # noqa: E402

GORE = gen_gore.GORE
TABLE = os.path.join(GORE, 'generated', 'takeover_table.txt')

# name -> (scope, type, default). The design's section 6 rows and budgets, with section 8's answers.
REQUIRED = {
    'rsqgo_on': ('server', 'bool', 'false'),          # master switch: off until the phases ship
    'rsqgo_amount': ('server', 'int', '2'),
    'rsqgo_fx': ('user', 'int', '2'),
    'rsqgo_residue': ('server', 'int', '2'),
    'rsqgo_drips': ('user', 'bool', 'true'),
    'rsqgo_screen': ('user', 'bool', 'true'),
    'rsqgo_platform': ('server', 'int', '0'),
    'rsqgo_fly_all': ('server', 'int', '192'), 'rsqgo_fly_some': ('server', 'int', '96'), 'rsqgo_fly_quest': ('server', 'int', '96'),
    'rsqgo_floor_all': ('server', 'int', '512'), 'rsqgo_floor_some': ('server', 'int', '192'),
    'rsqgo_floor_quest': ('server', 'int', '160'),
    'rsqgo_ceil_all': ('server', 'int', '128'), 'rsqgo_ceil_some': ('server', 'int', '48'), 'rsqgo_ceil_quest': ('server', 'int', '48'),
    'rsqgo_meat_all': ('server', 'int', '160'), 'rsqgo_meat_some': ('server', 'int', '64'), 'rsqgo_meat_quest': ('server', 'int', '64'),
    'rsqgo_spray_level': ('server', 'int', '2'),
    'rsqgo_part_all': ('user', 'int', '50'), 'rsqgo_part_some': ('user', 'int', '25'), 'rsqgo_part_quest': ('user', 'int', '25'),
    'rsqgo_guard_pc': ('user', 'bool', 'false'), 'rsqgo_guard_quest': ('user', 'bool', 'true'),
}
CVAR_RE = re.compile(r'^\s*((?:(?:server|user|nosave|noarchive|cheat|latch|unsafe)\s+)*)(int|float|bool|string|color)\s+'
                     r'(\w+)\s*(?:=\s*([^;]*))?;', re.I)

problems, notes = [], []


def bad(msg):
    problems.append(msg)


def read(p):
    try:
        return open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        return None


def strip_c(t):
    return decorate.strip_comments(t)


# ------------------------------------------------------------------ the table
def check_table(bd, xm):
    t = read(TABLE)
    if t is None:
        bad('no %s: run gen_gore.py' % TABLE)
        return
    lines = [ln for ln in t.split('\n') if ln and not ln.startswith('#')]
    if not lines or tuple(lines[0].split('\t')) != gen_gore.HEAD:
        bad('takeover_table.txt: header is not %s' % '\\t'.join(gen_gore.HEAD))
        return
    rows, seen = [], {}
    for n, ln in enumerate(lines[1:], 2):
        f = ln.split('\t')
        if len(f) != len(gen_gore.HEAD):
            bad('table row %d: %d columns, want %d' % (n, len(f), len(gen_gore.HEAD)))
            continue
        r = dict(zip(gen_gore.HEAD, f))
        k = r['class'].lower()
        if k in seen:
            bad('class claimed twice in the table: %s (rows %d and %d)' % (r['class'], seen[k], n))
        seen[k] = n
        c = gen_gore.CAT_BY_LABEL.get(r['category'])
        if not c:
            bad('%s: unknown category "%s"' % (r['class'], r['category']))
        elif r['phase'] != str(c[2]) or r['owner'] != c[3]:
            bad('%s: category %s wants phase %s owner %s, row has %s / %s' % (r['class'], c[1], c[2], c[3], r['phase'], r['owner']))
        rows.append(r)

    world, cat, fresh = gen_gore.build(bd, xm)
    for r in rows:
        if r['class'].lower() not in world.cls:
            bad('%s: no longer defined in either pk3' % r['class'])
    # Score's set
    ss = gen_gore.score_set()
    if not ss:
        notes.append('RSQ Score head.zs FROM[] not found: Score overlap not checked')
    for r in rows:
        if r['class'].lower() in ss and r['owner'] != 'score':
            bad('%s: in RSQ Score\'s takeover set but owned by %s here (claimed twice)' % (r['class'], r['owner']))
    # gaps: descendants of table classes
    intable = set(seen)
    for k in sorted(intable):
        if k not in world.cls:
            continue
        for d in world.descendants(k):
            if d not in intable and cat.memo.get(d) != 'exclude':
                bad('category gap: %s (child of %s) is not in the table and not excluded' % (world.cls[d].name, world.cls[k].name))
    others = [r['class'] for r in rows if r['category'] == 'other']
    if others:
        notes.append('"other" (helpers inheriting gore classes, left to BD until a phase decides): ' + ', '.join(others))
    # stale?
    want = {r['key']: r['label'] for r in fresh}
    have = {r['class'].lower(): r['category'] for r in rows}
    if want != have:
        add = sorted(set(want) - set(have))
        gone = sorted(set(have) - set(want))
        moved = sorted(k for k in set(want) & set(have) if want[k] != have[k])
        bad('takeover_table.txt is stale (regenerate with gen_gore.py): %d new, %d gone, %d recategorised%s' % (
            len(add), len(gone), len(moved), (': ' + ', '.join((add + gone + moved)[:12])) if (add or gone or moved) else ''))
    notes.append('table: %d rows, %d categories used' % (len(rows), len({r['category'] for r in rows})))


# ------------------------------------------------------------------ Gore's own files
def check_cvars():
    t = read(os.path.join(GORE, 'CVARINFO.txt'))
    if t is None:
        bad('no CVARINFO.txt')
        return {}
    cv = {}
    for n, ln in enumerate(strip_c(t).split('\n'), 1):
        if not ln.strip():
            continue
        m = CVAR_RE.match(ln)
        if not m:
            bad('CVARINFO line %d does not parse: %s' % (n, ln.strip()))
            continue
        mods = m.group(1).lower().split()
        scope = 'server' if 'server' in mods else ('user' if 'user' in mods else 'none')
        name, typ, val = m.group(3).lower(), m.group(2).lower(), (m.group(4) or '').strip().lower()
        if not name.startswith('rsqgo_'):
            bad('CVARINFO: %s is not rsqgo_-prefixed' % name)
        if name in cv:
            bad('CVARINFO: %s declared twice' % name)
        cv[name] = (scope, typ, val, 'noarchive' in mods)
    for name, (scope, typ, val) in REQUIRED.items():
        if name not in cv:
            bad('CVARINFO: missing %s (design section 6)' % name)
            continue
        s, ty, v, _ = cv[name]
        if (s, ty) != (scope, typ):
            bad('CVARINFO: %s is %s %s, want %s %s' % (name, s, ty, scope, typ))
        if v != val:
            bad('CVARINFO: %s defaults to %s, want %s' % (name, v, val))
    return cv


def check_menu(cv):
    p = os.path.join(GORE, 'MENUDEF.txt')
    t = read(p)
    if t is None:
        notes.append('no MENUDEF.txt yet (phase 1 adds the menu): menu checks skipped')
        return
    t = strip_c(t)
    used = {x.lower() for x in re.findall(r'"(rsqgo_\w+)"', t, re.I)}
    for name in sorted(used - set(cv)):
        bad('MENUDEF names %s, which CVARINFO does not declare' % name)
    for name in sorted(set(cv) - used):
        if not cv[name][3]:
            bad('CVARINFO %s has no menu row (design/MENU_STANDARD.md: every cvar keeps a row)' % name)
    subs = re.findall(r'^\s*Submenu\s+"([^"]+)"', t, re.I | re.M)
    if subs and any(s != 'Test and Debug' for s in subs):
        bad('MENUDEF sub menus %s: the front page has one, "Test and Debug"' % subs)


def check_code(cv):
    zs = []
    for d, _, files in os.walk(os.path.join(GORE, 'zscript')):
        for f in files:
            if f.lower().endswith(('.zs', '.zsc', '.txt')):
                zs.append(os.path.join(d, f))
    zs.append(os.path.join(GORE, 'zscript.txt'))
    classes, names = set(), set()
    for p in zs:
        t = strip_c(read(p) or '')
        classes |= {c.lower() for c in re.findall(r'^\s*class\s+(\w+)', t, re.I | re.M)}
        # cvars are lower case (rsqgo_on); classes are RSQGO_ (RSQGO_Manager) and the RNG is RSQGO_Play
        names |= set(re.findall(r'\b(rsqgo_[a-z0-9_]+)\b', t))
        for inc in re.findall(r'#include\s+"([^"]+)"', t):
            if not os.path.isfile(os.path.join(GORE, inc)):
                bad('%s includes %s, which does not exist' % (os.path.relpath(p, GORE), inc))
    for name in sorted(names - set(cv)):
        bad('ZScript uses %s, which CVARINFO does not declare' % name)
    mi = strip_c(read(os.path.join(GORE, 'MAPINFO.txt')) or '')
    for blk in re.findall(r'AddEventHandlers\s*=\s*([^\n}]*)', mi, re.I):
        for h in re.findall(r'"([^"]+)"', blk):
            if h.lower() not in classes:
                bad('MAPINFO adds handler %s, which no ZScript class defines' % h)
    bs = read(os.path.join(GORE, 'build.sh'))
    if bs is None:
        bad('no build.sh')
    else:
        m = re.search(r'zip\s+-q\s+-r\s+-X\s+\S+\s+(.*?)(?:&&|2>|$)', bs, re.M)
        for item in (m.group(1).split() if m else []):
            if not os.path.exists(os.path.join(GORE, item)):
                bad('build.sh packs %s, which does not exist' % item)


def main(argv):
    if len(argv) != 3:
        print(__doc__.strip().split('\n\n')[1])
        return 2
    for p in argv[1:]:
        if not os.path.isfile(p):
            print('gore_lint: no such pk3: ' + p)
            return 2
    check_table(argv[1], argv[2])
    cv = check_cvars()
    check_menu(cv)
    check_code(cv)
    for n in notes:
        print('note: ' + n)
    for p in problems:
        print('PROBLEM: ' + p)
    print('gore_lint: %s (%d problem%s)' % ('FAIL' if problems else 'ok', len(problems), '' if len(problems) == 1 else 's'))
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
