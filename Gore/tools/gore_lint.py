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
  - every rsqgo_ name the ZScript uses is declared; MAPINFO's handlers are ZScript classes; build.sh's include list exists
    and packs the generated pk3 content.
PHASE 1 (the cards, written by gen_gore.py through cards.py):
  - zscript/rsqgo/cards.zs, TEXTURES.txt, ANIMDEFS.txt and generated/cards_summary.txt are current (regenerated in a
    temporary folder and compared byte for byte);
  - every card class is a phase 1, Gore-owned table class (never RSQ Score's, never an excluded one);
  - every TEXTURES and ANIMDEFS name is RSQGO_-prefixed, and NO ANIMDEFS entry names a texture BD22 or XMVE has (an
    ANIMDEFS animation is global to its texture name: animating one of BD's would change how BD's own actors draw);
  - every TEXTURES patch exists in BD22 or XMVE;
  - the menu has the master switch on its front page and the debug log on Test and Debug;
  - ZScript traps: a name declared twice in one class regardless of case (a const RING and a field ring), a member
    named with a ZScript keyword, an `out Vector` parameter.
"""
import os
import re
import shutil
import sys
import tempfile
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import decorate  # noqa: E402
import gen_gore  # noqa: E402
import cards as cardsmod  # noqa: E402
import chunk_lint  # noqa: E402  (phase 3)

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
    'rsqgo_spray_level': ('server', 'int', '2'),   # owner 2026-11-27: Normal, although BD plays Low here (CVARINFO.txt note)
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
    # cvars are lower case (rsqgo_on); the menu pages and value lists are RSQGO_ (RSQGO_Options, RSQGO_Amount)
    used = set(re.findall(r'"(rsqgo_[a-z0-9_]+)"', t))
    for name in sorted(used - set(cv)):
        bad('MENUDEF names %s, which CVARINFO does not declare' % name)
    for name in sorted(set(cv) - used):
        if not cv[name][3]:
            bad('CVARINFO %s has no menu row (design/MENU_STANDARD.md: every cvar keeps a row)' % name)
    # the front page's sub menus (the series parent block's own Submenu row, in AddOptionMenu "RSQ_RSOptions", is not one)
    front = re.search(r'OptionMenu\s+"RSQGO_Options"[^{]*\{(.*?)\n\}', t, re.S)
    subs = re.findall(r'^\s*Submenu\s+"([^"]+)"', front.group(1) if front else '', re.I | re.M)
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
        items = m.group(1).split() if m else []
        for item in items:
            if not os.path.exists(os.path.join(GORE, item)):
                bad('build.sh packs %s, which does not exist' % item)
        for need in ('MENUDEF.txt', 'zscript', 'graphics'):
            if need not in items:
                bad('build.sh does not pack %s' % need)


# ------------------------------------------------------------------ phase 1
ZS_KEYWORDS = {'until', 'var', 'let', 'loop', 'stop', 'wait', 'fail', 'goto', 'states', 'default', 'class', 'struct',
               'enum', 'const', 'native', 'static', 'action', 'readonly', 'internal', 'transient', 'ui', 'play',
               'clearscope', 'virtual', 'override', 'final', 'version', 'deprecated', 'property', 'flagdef', 'mixin',
               'extend', 'replaces', 'abstract', 'meta', 'super', 'self', 'null', 'true', 'false', 'out', 'in',
               'is', 'sizeof', 'alignof', 'foreach', 'switch', 'case', 'break', 'continue', 'return', 'do', 'while',
               'for', 'if', 'else', 'new', 'vector2', 'vector3', 'array', 'map', 'name', 'sound', 'state', 'color'}
# Also refused as a local or parameter name (the compile check found `bool play`): scope words, state modifiers.
LOCAL_KEYWORDS = {'virtualscope', 'latent', 'bright', 'fast', 'slow', 'nodelay', 'canraise', 'light', 'offset', 'base',
                  'int', 'bool', 'double', 'string', 'float', 'uint', 'object', 'vector4'}
PHASE1_LABELS = ('hit blood', 'flying+trail', 'mist+jet', 'liquid check')


def pk3_lumps(paths):
    """Every lump name (file base name without extension, upper case) and every TEXTURES-defined name in the packs."""
    names = set()
    for path in paths:
        z = zipfile.ZipFile(path)
        for n in z.namelist():
            if n.endswith('/'):
                continue
            base = n.replace('\\', '/').split('/')[-1]
            stem = base.split('.')[0]
            names.add(stem.upper())
            if stem.lower() == 'textures':
                tx = z.read(n).decode('latin-1')
                for m in re.finditer(r'^\s*(?:texture|walltexture|flat|sprite|graphic)\s+(?:optional\s+)?"?([^",\s]+)',
                                     tx, re.I | re.M):
                    names.add(m.group(1).upper())
    return names


def check_phase1(bd, xm):
    out = {k: os.path.join(GORE, v) for k, v in gen_gore.PHASE1_OUT.items()}
    for p in out.values():
        if not os.path.isfile(p):
            bad('phase 1: %s is missing (run gen_gore.py)' % os.path.relpath(p, GORE))
            return
    # current? (regenerated into a temporary folder, compared byte for byte)
    world, cat, rows = gen_gore.build(bd, xm)
    baked = set()
    tmp = tempfile.mkdtemp(prefix='rsqgo_lint_')
    try:
        gen_gore.write_phase1(world, rows, bd, xm, root=tmp)
        for k, rel in gen_gore.PHASE1_OUT.items():
            with open(os.path.join(tmp, rel), 'rb') as fa, open(out[k], 'rb') as fb:
                # line endings aside: git (core.autocrlf) checks text out with CRLF on Windows
                if fa.read().replace(b'\r\n', b'\n') != fb.read().replace(b'\r\n', b'\n'):
                    bad('phase 1: %s is stale (regenerate with gen_gore.py)' % rel)
        # the baked frames: the same files, byte for byte, and nothing else in the folder
        ours = os.path.join(GORE, cardsmod.BAKE_DIR)
        fresh = os.path.join(tmp, cardsmod.BAKE_DIR)
        have = set(os.listdir(ours)) if os.path.isdir(ours) else set()
        want = set(os.listdir(fresh)) if os.path.isdir(fresh) else set()
        for fn in sorted(want - have):
            bad('phase 1: baked frame %s/%s is missing (regenerate with gen_gore.py)' % (cardsmod.BAKE_DIR, fn))
        for fn in sorted(have - want):
            bad('phase 1: %s/%s is not a current bake (regenerate with gen_gore.py)' % (cardsmod.BAKE_DIR, fn))
        for fn in sorted(have & want):
            with open(os.path.join(ours, fn), 'rb') as fa, open(os.path.join(fresh, fn), 'rb') as fb:
                if fa.read() != fb.read():
                    bad('phase 1: baked frame %s/%s is stale (regenerate with gen_gore.py)' % (cardsmod.BAKE_DIR, fn))
        baked = {fn.split('.')[0].upper() for fn in have}
        notes.append('phase 1: %d baked frames in %s' % (len(have), cardsmod.BAKE_DIR))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    # card classes against the table and RSQ Score's set
    tab = {r['key']: r for r in rows}
    ss = gen_gore.score_set()
    zs = strip_c(read(out['zscript']) or '')
    cards = re.findall(r'^class\s+RSQGO_K_(\w+)\s*:', zs, re.M)
    for c in cards:
        r = tab.get(c.lower())
        if r is None:
            bad('phase 1: card %s is not a table class' % c)
        elif r['label'] not in PHASE1_LABELS or r['owner'] != 'gore':
            bad('phase 1: card %s is %s / %s, not a phase 1 Gore class' % (c, r['label'], r['owner']))
        if c.lower() in ss:
            bad('phase 1: card %s is in RSQ Score\'s takeover set (claimed twice)' % c)
    notes.append('phase 1: %d cards' % len(cards))
    # the tracks' textures: every AddTex names a baked frame of ours that exists, every baked frame is used, and no
    # retired particle file (TEXTURES / ANIMDEFS / GLDEFS of the particle drafts) is left in the pk3's root
    theirs = pk3_lumps([bd, xm])
    texnames = re.findall(r'AddTex\("([^"]+)"\)', zs)
    for n in texnames:
        if n.upper() not in baked:
            bad('phase 1: AddTex("%s") has no baked frame in %s' % (n, cardsmod.BAKE_DIR))
        if n.upper() in theirs:
            bad('phase 1: baked frame name %s is also a name in BD22 / XMVE' % n)
    unused = sorted(baked - {n.upper() for n in texnames})
    if unused:
        bad('phase 1: %d baked frames no track uses, e.g. %s' % (len(unused), unused[0]))
    for old in gen_gore.PHASE1_RETIRED:
        if os.path.isfile(os.path.join(GORE, old)):
            bad('phase 1: %s is a retired particle-draft file (regenerate with gen_gore.py to remove it)' % old)
    # the tracks themselves: keyframes in order, textures in range, a VisualThinker class to play them
    tracks = re.findall(r'Add(?:Var|Puff|Splash|WSplash)\(([^)]*)\);((?:\s*AddKf\([^)]*\);)*)', zs)
    bad_tr = 0
    for head, kfs in tracks:
        ticks = [int(m.split(',')[0]) for m in re.findall(r'AddKf\(([^)]*)\)', kfs)]
        texs = [int(m.split(',')[1]) for m in re.findall(r'AddKf\(([^)]*)\)', kfs)]
        if not ticks or ticks != sorted(ticks) or ticks[0] != 0 or any(x >= len(texnames) for x in texs):
            bad_tr += 1
    if bad_tr:
        bad('phase 1: %d tracks with keyframes out of order, missing, or naming a texture out of range' % bad_tr)
    if 'class RSQGO_VT : VisualThinker' not in strip_c(read(os.path.join(GORE, 'zscript', 'rsqgo', 'emit.zs')) or ''):
        bad('phase 1: no RSQGO_VT (the VisualThinker that plays the tracks) in zscript/rsqgo/emit.zs')
    notes.append('phase 1: %d tracks, %d textures (baked BD frames, none named like BD22\'s or XMVE\'s)' % (
        len(tracks), len(texnames)))


def check_menu_rows():
    t = read(os.path.join(GORE, 'MENUDEF.txt'))
    if t is None:
        return
    t = strip_c(t)
    pages = {m.group(1): m.group(2) for m in re.finditer(r'OptionMenu\s+"(\w+)"[^{]*\{(.*?)\n\}', t, re.S)}
    if not re.search(r'^\s*Option\s+"[^"]+",\s*"rsqgo_on"', pages.get('RSQGO_Options', ''), re.M):
        bad('MENUDEF: the front page (RSQGO_Options) has no master switch row (rsqgo_on)')
    if '"rsqgo_debug"' not in pages.get('RSQGO_Test', ''):
        bad('MENUDEF: Test and Debug (RSQGO_Test) has no debug log row (rsqgo_debug)')


def class_bodies(t):
    """(class name, top-level body text, full body text) for every class / extend class in a ZScript file."""
    out = []
    for m in re.finditer(r'^(?:extend\s+)?class\s+(\w+)[^{;]*\{', t, re.M):
        i, depth = m.end(), 1
        while i < len(t) and depth:
            if t[i] == '{':
                depth += 1
            elif t[i] == '}':
                depth -= 1
            i += 1
        body = t[m.end():i - 1]
        top, d = [], 0
        for ch in body:
            if ch == '{':
                d += 1
            elif ch == '}':
                d -= 1
            elif d == 0:
                top.append(ch)
        out.append((m.group(1), ''.join(top), body))
    return out


MEMBER_RE = re.compile(r'^\s*(?:(?:transient|private|protected|static|readonly|native|virtual|override|final|clearscope|'
                       r'ui|play|action)\s+)*(?:Array\s*<[^;()]*>|Map\s*<[^;()]*>|Class\s*<\s*\w+\s*>|[A-Za-z_]\w*)\s+'
                       r'([A-Za-z_]\w*)\s*([;,=(].*)?$')


def check_zs_traps():
    """Per class: a name declared twice regardless of case, a member named with a keyword, an out Vector parameter."""
    decl = {}
    for d, _, fs in os.walk(os.path.join(GORE, 'zscript')):
        for f in sorted(fs):
            if not f.lower().endswith('.zs'):
                continue
            p = os.path.join(d, f)
            rel = os.path.relpath(p, GORE)
            t = strip_c(read(p) or '')
            t = re.sub(r'"(?:[^"\\]|\\.)*"', '""', t)
            if re.search(r'\bout\s+Vector[23]\b', t):
                bad('%s: an `out Vector` parameter (it compiles, then aborts the VM)' % rel)
            # locals and parameters too: `bool play` is "Unexpected 'play'" (scope words, type names, state words)
            for m in re.finditer(r'\b(?:bool|int|uint|double|float|String|Name|Vector2|Vector3|Sound|Color|let|Actor|Sector)'
                                 r'\s+([A-Za-z_]\w*)\s*[,;=)]', t):
                if m.group(1).lower() in ZS_KEYWORDS | LOCAL_KEYWORDS:
                    bad('%s: a variable or parameter named %s, a ZScript keyword' % (rel, m.group(1)))
            for cname, top, body in class_bodies(t):
                names = re.findall(r'\bconst\s+(\w+)\s*=', top)
                for stmt in re.split(r'[;\n]', top):
                    s = stmt.strip()
                    if not s or s.startswith(('const', 'enum', 'property', 'default', 'states', 'flagdef')):
                        continue
                    mm = MEMBER_RE.match(s)
                    if not mm:
                        continue
                    names.append(mm.group(1))
                    rest = mm.group(2) or ''
                    if rest.startswith(','):            # int a, b, c;
                        names += [x.strip() for x in rest[1:].split(',') if re.match(r'^\w+$', x.strip())]
                for en in re.findall(r'\benum\s+\w+\s*\{([^}]*)\}', body):
                    names += [x.split('=')[0].strip() for x in en.split(',') if x.strip()]
                for n in names:
                    decl.setdefault(cname.lower(), {}).setdefault(n.lower(), set()).add((rel, n))
                    if n.lower() in ZS_KEYWORDS:
                        bad('%s: class %s member %s is a ZScript keyword' % (rel, cname, n))
    for cl, ns in sorted(decl.items()):
        for k, lst in sorted(ns.items()):
            if len({n for _, n in lst}) > 1:
                bad('class %s declares %s twice (identifiers ignore case): %s' % (
                    cl, k, ', '.join('%s in %s' % (n, f) for f, n in sorted(lst))))


def check_name_vs_cvar():
    """A class, struct or enum named like one of our cvars, ignoring case, hides the cvar: every read of it fails with
    "Invalid global identifier" (2026-11-27: class RSQGO_Residue vs cvar rsqgo_residue)."""
    cvars = set(m.lower() for m in re.findall(r'\b(rsqgo_\w+)\s*=', read(os.path.join(GORE, 'CVARINFO.txt')) or ''))
    for d, _, fs in os.walk(os.path.join(GORE, 'zscript')):
        for f in sorted(fs):
            if not f.lower().endswith('.zs'):
                continue
            p = os.path.join(d, f)
            for m in re.finditer(r'^\s*(?:class|struct|enum|mixin\s+class)\s+(\w+)', strip_c(read(p) or ''), re.M):
                if m.group(1).lower() in cvars:
                    problems.append('%s: type %s has the name of cvar %s (names ignore case; it hides the cvar)'
                                    % (os.path.relpath(p, GORE), m.group(1), m.group(1).lower()))


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
    check_menu_rows()
    check_code(cv)
    check_phase1(argv[1], argv[2])
    check_zs_traps()
    chunk_lint.check(argv[1], argv[2], bad, notes.append, strict=True)
    check_name_vs_cvar()
    for n in notes:
        print('note: ' + n)
    for p in problems:
        print('PROBLEM: ' + p)
    print('gore_lint: %s (%d problem%s)' % ('FAIL' if problems else 'ok', len(problems), '' if len(problems) == 1 else 's'))
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
