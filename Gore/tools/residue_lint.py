#!/usr/bin/env python3
"""residue_lint.py -- RSQ Gore PHASE 2 lint: the residue cards, their pk3 outputs and the runtime that reads them.

    python -I Gore/tools/residue_lint.py <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>

Also a module: gore_lint.py can call `residue_lint.check(bd_pk3, xmve_pk3)` -> (errors, warnings, notes).

Fails (exit 1) when:
  * a phase 2 table class (floor spot+pool, ceiling, drip, smear) is neither a card nor left with a written reason;
  * a card's BD class is missing from the packs, comes from BD's Dead.dec (map decorations: never taken over or
    recycled), is not owned by Gore in the table, or is also a phase 1 card (cards.zs RSQGO_K_<name>);
  * a class a card names (smearer, liquid spot, ceiling spot, drip, drip spot, under-water child) exists nowhere;
  * the generated outputs (residue_cards.zs, MODELDEF.residue, TEXTURES.residue, ANIMDEFS.residue, the summary) are
    stale, i.e. differ from a fresh run of residue_gen.py;
  * MODELDEF.residue lacks one of BD's model blocks for a visible class, or names a class that is not ours;
  * an ANIMDEFS.residue or TEXTURES.residue name is not RSQGO_RL.., or clashes with phase 1's TEXTURES.txt;
    GLDEFS.residue is not one nomipmap line per drip texture; graphics/rsqgo_res differs from a fresh bake;
  * a floor or ceiling card shows more than 6 frames (RSQGO_ResidueRings.Reveal labels V0..V5);
  * a residue .zs file declares a class twice (case-insensitive, across all of zscript/rsqgo/), declares one member
    name twice in different case, uses a reserved word as a name, or reads a cvar by name that CVARINFO lacks
    (direct reads only: rsqgo_merge and rsqgo_smear_all are read with CVar.FindCVar and only warn).
Warns when the manager hooks or the zscript.txt / build.sh lines of the phase 2 report are not applied yet.
"""
import io
import os
import re
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import decorate      # noqa: E402
import residue_gen   # noqa: E402

GORE = os.path.dirname(HERE)
ZDIR = os.path.join(GORE, 'zscript', 'rsqgo')
RESIDUE_ZS = ('residue.zs', 'residue_data.zs', 'residue_cards.zs')
RESERVED = {'play', 'ui', 'until', 'version', 'native', 'action', 'out', 'in', 'readonly', 'meta', 'latent', 'internal',
            'clearscope', 'virtualscope', 'transient', 'deprecated', 'static', 'final', 'abstract', 'override',
            'virtual', 'private', 'protected', 'vararg', 'states', 'default', 'property', 'flagdef', 'mixin',
            'extend', 'struct', 'class', 'enum', 'const', 'return', 'sizeof', 'alignof', 'is', 'super', 'self'}
OPTIONAL_CVARS = ('rsqgo_merge', 'rsqgo_smear_all')


def read(p):
    with open(p, encoding='utf-8', errors='replace') as fh:
        return fh.read()


def strip_zs(t):
    t = decorate.strip_comments(t)
    return decorate.strip_strings(t)


def fresh_outputs(bd, xmve):
    """Run the generator into a temp dir; return {output name: text}."""
    tmp = tempfile.mkdtemp(prefix='rsqgo_rlint_')
    names = {'zs': os.path.join(tmp, 'residue_cards.zs'), 'md': os.path.join(tmp, 'MODELDEF.residue'),
             'tex': os.path.join(tmp, 'TEXTURES.residue'), 'anim': os.path.join(tmp, 'ANIMDEFS.residue'), 'gl': os.path.join(tmp, 'GLDEFS.residue'),
             'sum': os.path.join(tmp, 'residue_summary.txt')}
    packs = [(bd, 'BD'), (xmve, 'XMVE')]
    world, cards, left, looks, flats, md, idx = residue_gen.build(packs)
    bd_name = os.path.basename(bd)
    residue_gen.write_zs(cards, looks, flats, idx, names['zs'], bd_name)
    residue_gen.write_modeldef(cards, md, names['md'], bd_name)
    plan, bakes = residue_gen.make_bakes(looks, packs, residue_gen.DOOM2_WAD)
    residue_gen.write_textures(looks, names['tex'], bd_name, plan)
    residue_gen.write_animdefs(looks, names['anim'])
    residue_gen.write_gldefs(looks, names['gl'])
    residue_gen.write_summary(cards, left, looks, flats, names['sum'], bd_name, os.path.basename(xmve))
    out = {k: read(v) for k, v in names.items()}
    for v in names.values():
        os.remove(v)
    os.rmdir(tmp)
    out['bakes'] = bakes
    return world, cards, left, looks, md, out


def zs_checks(errors, warnings):
    """Class names across zscript/rsqgo, member case clashes and reserved names in the residue files."""
    classes = {}
    for fn in sorted(os.listdir(ZDIR)):
        if not fn.endswith('.zs'):
            continue
        t = strip_zs(read(os.path.join(ZDIR, fn)))
        for m in re.finditer(r'^\s*class\s+(\w+)', t, re.M):
            k = m.group(1).lower()
            if k in classes:
                errors.append('class %s declared twice (%s and %s)' % (m.group(1), classes[k], fn))
            else:
                classes[k] = fn
    for fn in RESIDUE_ZS:
        p = os.path.join(ZDIR, fn)
        if not os.path.exists(p):
            errors.append('missing %s' % fn)
            continue
        t = strip_zs(read(p))
        # split into class / extend bodies
        for m in re.finditer(r'^(?:extend\s+)?class\s+(\w+)[^{]*\{', t, re.M):
            j = decorate.match_brace(t, m.end() - 1)
            body = t[m.end():j]
            names = {}
            # members at depth 0 of the class body: fields and methods
            depth, line_start = 0, 0
            top = []
            k = 0
            while k < len(body):
                ch = body[k]
                if ch == '{':
                    depth += 1
                elif ch == '}':
                    depth -= 1
                elif depth == 0:
                    top.append(ch)
                    k += 1
                    continue
                if depth == 0 and ch == '}':
                    top.append(';')
                k += 1
            toplevel = ''.join(top)
            for mm in re.finditer(r'(?:^|[;\n])\s*(?:(?:static|const|transient|private|protected|virtual|override|'
                                  r'final|native|readonly|clearscope|play|ui)\s+)*'
                                  r'(?:Array\s*<[^;]*?>\s*|Map\s*<[^;]*?>\s*|Class\s*<\s*\w+\s*>\s*|[A-Za-z_]\w*\s+)'
                                  r'([A-Za-z_]\w*)\s*(?=[;=(,\[])', toplevel):
                nm = mm.group(1)
                if nm.lower() in ('return', 'if', 'else', 'property', 'default', 'states', 'enum'):
                    continue
                prev = names.get(nm.lower())
                if prev and prev != nm:
                    errors.append('%s %s: member names %s and %s differ only in case' % (fn, m.group(1), prev, nm))
                names.setdefault(nm.lower(), nm)
        # reserved words used as names: "<type> <word>" declarations and parameters
        for mm in re.finditer(r'\b(?:int|uint|double|bool|String|Name|Vector2|Vector3|Actor|let)\s+([A-Za-z_]\w*)\b', t):
            if mm.group(1).lower() in RESERVED:
                errors.append('%s: reserved word "%s" used as a name' % (fn, mm.group(1)))
        if re.search(r'\bout\s+Vector[23]\b', t):
            errors.append('%s: an out Vector parameter (aborts the VM in this engine)' % fn)


def cvar_checks(errors, warnings):
    cvi = read(os.path.join(GORE, 'CVARINFO.txt'))
    declared = {m.group(1).lower() for m in re.finditer(r'^\s*(?:server|user|nosave)[^/\n]*?\b(rsqgo_\w+)\s*=', cvi, re.M)}
    for fn in RESIDUE_ZS:
        p = os.path.join(ZDIR, fn)
        if not os.path.exists(p):
            continue
        raw = decorate.strip_comments(read(p))
        bare = decorate.strip_strings(raw)
        for m in sorted(set(re.findall(r'\b(rsqgo_\w+)\b', bare))):
            if m.lower() not in declared:
                errors.append('%s reads cvar %s directly, but CVARINFO.txt does not declare it' % (fn, m))
        for m in sorted(set(re.findall(r'"(rsqgo_\w+)"', raw))):
            if m.lower() not in declared:
                (warnings if m in OPTIONAL_CVARS else errors).append(
                    '%s reads cvar %s by name; CVARINFO.txt does not declare it yet%s' % (
                        fn, m, ' (optional: the code treats it as its default)' if m in OPTIONAL_CVARS else ''))


def hook_checks(warnings, notes):
    mgr = read(os.path.join(ZDIR, 'manager.zs'))
    if 'RSQGO_ResidueRings' not in mgr:
        warnings.append('manager.zs has no RSQGO_ResidueRings hooks yet (phase 2 is inert until they are applied)')
    else:
        for need in ('TakeOver(', 'WorldTic(', 'RSQGO_ResidueRings.Get('):
            if need not in mgr:
                warnings.append('manager.zs mentions RSQGO_ResidueRings but lacks %s' % need)
    zt = read(os.path.join(GORE, 'zscript.txt'))
    for fn in RESIDUE_ZS:
        if fn not in zt:
            warnings.append('zscript.txt does not #include zscript/rsqgo/%s yet' % fn)
    bs = read(os.path.join(GORE, 'build.sh'))
    for fn in ('MODELDEF.residue', 'TEXTURES.residue', 'ANIMDEFS.residue', 'GLDEFS.residue'):
        if fn not in bs:
            warnings.append('build.sh does not pack %s yet' % fn)


def check(bd, xmve):
    errors, warnings, notes = [], [], []
    world, cards, left, looks, md, fresh = fresh_outputs(bd, xmve)
    # ---- outputs current
    disk = {'zs': os.path.join(ZDIR, 'residue_cards.zs'), 'md': os.path.join(GORE, 'MODELDEF.residue'),
            'tex': os.path.join(GORE, 'TEXTURES.residue'), 'anim': os.path.join(GORE, 'ANIMDEFS.residue'), 'gl': os.path.join(GORE, 'GLDEFS.residue'),
            'sum': os.path.join(GORE, 'generated', 'residue_summary.txt')}
    for k, p in disk.items():
        if not os.path.exists(p):
            errors.append('missing %s (run residue_gen.py)' % os.path.relpath(p, GORE))
        elif read(p).replace('\r\n', '\n') != fresh[k]:
            errors.append('%s is stale (run residue_gen.py)' % os.path.relpath(p, GORE))
    # ---- coverage of the table
    rows = residue_gen.read_table()
    card_names = {c.name.lower(): c for c in cards}
    left_names = {n.lower(): why for n, why in left}
    for r in rows:
        k = r['class'].lower()
        if k not in card_names and not left_names.get(k):
            errors.append('table class %s (%s) is neither a card nor left with a reason' % (r['class'], r['cat']))
        if k in card_names and r['owner'] != 'gore':
            errors.append('%s is owned by %s in the table, not Gore' % (r['class'], r['owner']))
    # ---- phase 1 overlap, Dead.dec, existence
    p1 = set()
    cz = os.path.join(ZDIR, 'cards.zs')
    if os.path.exists(cz):
        p1 = {m.lower() for m in re.findall(r'\bclass\s+RSQGO_K_(\w+)', read(cz))}
    for c in cards:
        k = c.name.lower()
        if k not in world.cls:
            errors.append('card %s: no such class in the packs' % c.name)
            continue
        if 'dead.dec' in world.cls[k].source.lower():
            errors.append('card %s comes from Dead.dec (map decorations are never taken over)' % c.name)
        if k in p1:
            errors.append('card %s is also a phase 1 card (cards.zs)' % c.name)
        refs = list(getattr(c, 'refs', []))
        d = c.d
        if c.kind == residue_gen.RK_FLOOR and d.get('lcls'):
            refs.append(d['lcls'])
        if c.kind == residue_gen.RK_DRIP:
            refs += d.get('water_kids', [])
        for x in refs:
            if x.lower() not in world.cls:
                errors.append('card %s names %s, which exists nowhere' % (c.name, x))
        if c.kind in (residue_gen.RK_FLOOR, residue_gen.RK_CEIL):
            if len(d['frames']) > 6:
                errors.append('card %s shows %d frames (Reveal handles V0..V5)' % (c.name, len(d['frames'])))
        # a gravity missile that explodes on landing (no A_CheckFloor, not a Death=Spawn alias) must stand as one
        if c.kind == residue_gen.RK_FLOOR and d.get('missile') and not d.get('uses_check') and \
                d['stand'] == residue_gen.FS_VANISH:
            errors.append('floor card %s is a +MISSILE that explodes on landing but is not ST_MISSILE' % c.name)
        # a smearer's first check is its first look plus its A_Chase tics (residue.zs LockOn / AddZone)
        if c.kind == residue_gen.RK_SMEAR and d['chase'] != d['first'] - d['look_t'] - 1:
            errors.append('smearer %s: %d A_Chase tics, but its first check t%d is not look t%d + 1 + chase' % (
                c.name, d['chase'], d['first'], d['look_t']))
        if c.kind == residue_gen.RK_SMEAR and (d['period'] != 8 or d['dist'] != 60 or d['amount'] < 1):
            notes.append('smearer %s: period %d, distance %s, amount %d (not BD\'s usual 8 / 60 / 8)' % (
                c.name, d['period'], d['dist'], d['amount']))
    # ---- every launcher class carries its card's Speed (A_CustomMissile takes the spawned class's Speed)
    ztext = read(disk['zs']) if os.path.exists(disk['zs']) else ''
    for c in cards:
        if c.kind != residue_gen.RK_LAUNCH:
            continue
        pat = r'^class\s+' + re.escape(residue_gen.zs_class(c.name)) + r'\b[^\n]*\bSpeed\s+([\d.]+)\s*;'
        m = re.search(pat, ztext, re.M)
        if not m or abs(float(m.group(1)) - c.d['speed']) > 1e-6:
            errors.append('launcher class %s does not declare Speed %s (its card\'s)' % (
                residue_gen.zs_class(c.name), residue_gen.f(c.d['speed'])))
    # ---- the colour bakes (graphics/rsqgo_res): exactly the fresh set, byte for byte (none since run-time translation)
    bdir = os.path.join(GORE, residue_gen.BAKE_DIR)
    have = set(os.listdir(bdir)) if os.path.isdir(bdir) else set()
    want = {k + '.png' for k in fresh['bakes']}
    if have != want:
        errors.append('%s holds %d files, a fresh bake makes %d (run residue_gen.py)' % (
            residue_gen.BAKE_DIR, len(have), len(want)))
    else:
        for k, data in fresh['bakes'].items():
            with open(os.path.join(bdir, k + '.png'), 'rb') as fh:
                if fh.read() != data:
                    errors.append('%s/%s.png is stale (run residue_gen.py)' % (residue_gen.BAKE_DIR, k))
    # ---- MODELDEF completeness
    mtext = read(disk['md']) if os.path.exists(disk['md']) else ''
    ours = {}
    for m in re.finditer(r'\bModel\s+(\w+)\s*\{', mtext):
        ours[m.group(1).lower()] = ours.get(m.group(1).lower(), 0) + 1
    for name in ours:
        if not name.startswith('rsqgo_r_') or name[8:] not in card_names:
            errors.append('MODELDEF.residue names %s, not one of our residue classes' % name)
    for c in cards:
        if c.kind not in (residue_gen.RK_FLOOR, residue_gen.RK_CEIL):
            continue
        want = len(md.get(c.name.lower(), []))
        got = ours.get(('rsqgo_r_' + c.name).lower(), 0)
        if want != got:
            errors.append('MODELDEF.residue has %d block(s) for RSQGO_R_%s, BD has %d' % (got, c.name, want))
        if want == 0:
            notes.append('%s has no MODELDEF block in BD (drawn as its sprite, ours too)' % c.name)
    # ---- textures and animdefs names
    p1tex = set()
    tt = os.path.join(GORE, 'TEXTURES.txt')
    if os.path.exists(tt):
        p1tex = {m.lower() for m in re.findall(r'^Texture\s+"(\w+)"', read(tt), re.M)}
    rtex = re.findall(r'^Texture\s+"(\w+)"', read(disk['tex']) if os.path.exists(disk['tex']) else '', re.M)
    seen = set()
    for n in rtex:
        if not n.upper().startswith('RSQGO_RL'):
            errors.append('TEXTURES.residue names %s (not RSQGO_RL..)' % n)
        if n.lower() in p1tex:
            errors.append('TEXTURES.residue %s clashes with phase 1\'s TEXTURES.txt' % n)
        if n.lower() in seen:
            errors.append('TEXTURES.residue defines %s twice' % n)
        seen.add(n.lower())
    gl = read(disk['gl']) if os.path.exists(disk['gl']) else ''
    gnames = re.findall(r'^material\s+texture\s+"(\w+)"\s*\{\s*nomipmap\s*\}\s*$', gl, re.M)
    if sorted(n.lower() for n in gnames) != sorted(seen):
        errors.append('GLDEFS.residue does not hold exactly one nomipmap line per drip texture')
    an = read(disk['anim']) if os.path.exists(disk['anim']) else ''
    for n in re.findall(r'^\s*(?:texture|pic)\s+(\w+)', an, re.M | re.I):
        if not n.upper().startswith('RSQGO_RL') or n.lower() not in seen:
            errors.append('ANIMDEFS.residue names %s (not one of our RSQGO_RL textures)' % n)
    if looks.missing:
        errors.append('drip looks miss sprite frames: %s' % ', '.join(sorted(looks.missing)))
    # ---- ZScript and cvars
    zs_checks(errors, warnings)
    cvar_checks(errors, warnings)
    hook_checks(warnings, notes)
    notes.append('%d cards (%d floor, %d ceiling, %d launchers, %d drip spawners, %d drips, %d smearers), %d left: %s' % (
        len(cards), *[sum(1 for c in cards if c.kind == k) for k in range(6)], len(left),
        ', '.join(n for n, w in left) or '-'))
    return errors, warnings, notes


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    errors, warnings, notes = check(argv[1], argv[2])
    for n in notes:
        print('note: ' + n)
    for w in warnings:
        print('WARN: ' + w)
    for e in errors:
        print('FAIL: ' + e)
    print('residue_lint: %s (%d errors, %d warnings)' % ('FAIL' if errors else 'OK', len(errors), len(warnings)))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
