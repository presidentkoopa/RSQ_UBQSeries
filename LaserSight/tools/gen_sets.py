#!/usr/bin/env python3
"""gen_sets.py -- the series' other weapon sets, resolved to Brutal Doom's barrel rows, for the laser.

    python3 tools/gen_sets.py [--bd BD22_VR-Reloaded.pk3] <set.pk3> [<set.pk3> ...]
    e.g. python3 tools/gen_sets.py --bd /home/claude/presidentkoopa/rsq_bd_vr_reloaded/BD22_VR-Reloaded_2.0.4i.pk3 \
            ../weaponsets/WoS_Reloaded/RSQ_WeaponsOfSaturn_0.1.0.pk3 ../weaponsets/GNRC_Reloaded/GNRC_Reloaded_0.1.0.pk3

THE PROBLEM (owner 2026-11-13 01:42). The laser finds a gun's barrel by its CLASS NAME: muzzles.zs (the beam, measured
off BD22's held meshes) and bdbore.zs (the shot line, parsed from BD22 VR's muzzle.zs) are keyed by BD22's names
(BrutalPistol, Shot_Gun, Rifle...). A weapon set (WoS Reloaded, GNRC Reloaded) draws its guns with BD22's meshes and
fires them down BD22's barrel line -- its own copy of BD22 VR's muzzle.zs, looked up through its RSQ_Alias (alias.zs:
each RSQWS_ / RSQGW_ class, and its RSQ_Off_ copy, -> the BD22 gun whose tables it uses) -- but under its own names. The
laser found nothing, so its dot ran down the plain hand line, about 3.9 deg right and 3.4 deg low of the shots.

THE FIX, no hard link to any set (a set and BD22 VR are never loaded together: both define RSQ_Muzzle, RSQ_Alias...).
Every set's RSQ_Alias is called RSQ_Alias, so the laser cannot call it; this tool READS it and writes the laser's own
copy of the mapping (zscript/rsqls/sets.zs, RSQLS_Sets). A set class that is not loaded never matches, so the table
holds every set at once and the laser loads with any one of them, or none. Run it again when a set changes.

What it reads from each set pk3, and checks:
  zscript/rsq/alias.zs   RSQ_Alias.BD() and .Exact(): class -> BD22 gun, and an off-hand copy -> BD22's off-hand copy.
  zscript/rsq/muzzle.zs  RSQ_Muzzle.Muzzle(): the set's own rows (`w is 'X'` for a class of its own: the WoS 1911) and
                         every `RSQ_Alias.BD(w) == 'X'` row, checked against bdbore.zs; Bore(), checked against
                         bdbore.zs's BORE_YAW / BORE_PITCH. A mismatch is an error (regenerate bdbore.zs, or teach this).
  MODELDEF + meshes      each gun's held model at its Ready frame (the frame its zscript Ready state shows), measured the
                         way gen_beams.py measures BD22's (its own functions), against the BD22 beam placement that
                         frame selects in muzzles.zs. Within REUSE_MM / REUSE_DEG the set gun uses BD22's beam rows (no
                         new rods); further off it gets a placement of its own (its own rods: NLEN sprite frames each).
  --bd                   optional: BD22 VR's pk3, to report how many of the aliased frames the set's MODELDEF draws
                         exactly as BD22 VR does (same mesh bytes, frame, scale, offsets, angles).

A GUN THE SET FIRES FROM ITS OWN MUZZLE (the WoS 1911: muzzle.zs `w is 'RSQWS_1911'`, its own mesh, seated by
tools/seat_1911.py): its shot leaves its own muzzle down the set's one bore (BD22's). The dot follows exactly that line
(sets.zs OWN, read by bdbore.zs). Its beam, when its mesh's muzzle is off BD22's placement: drawn ON THE SHOT LINE, from
the point of that line level with the drawn muzzle's face -- the beam is the shot, and it leaves the mesh's muzzle.
(The mesh's own +x axis is not used for it: the seat turned it 4.7 / 4.2 deg, 1.2 deg off the line the set fires.)

Writes zscript/rsqls/sets.zs, VOXELDEF.sets (the own placements' rods: models/rsqls/beam/sNNkMM.kvx, sprites
LY00.., checked free in the load order 2026-11-13) and docs/SETS.txt.
"""
import argparse, hashlib, math, os, re, sys, zipfile
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import gen_beams as G
import numpy as np

REUSE_MM = 3.0      # a set gun's drawn muzzle this close to BD22's placement (and...)
REUSE_DEG = 0.25    # ...its barrel this close in direction) draws BD22's rods
SPRITE_PREFIX = 'LY'
BORE_TOL = 0.001    # degrees

def fmt(x): return '%.4f' % x

def read_text(z, name):
    n = {k.lower(): k for k in z.namelist()}.get(name.lower())
    return z.read(n).decode('latin-1') if n else None

def func_body(src, sig):
    m = re.search(sig + r'\s*\{', src)
    if not m: return None
    i, depth = m.end() - 1, 0
    for j in range(i, len(src)):
        if src[j] == '{': depth += 1
        elif src[j] == '}':
            depth -= 1
            if depth == 0: return src[i + 1:j]
    return None

def parse_alias(src):
    """-> {class: bd}, {class: exact}: RSQ_Alias.BD and .Exact, exactly as written."""
    def rows(body):
        out = {}
        for cond, ret in re.findall(r"if \(([^)]*)\)\s*return '(\w+)';", body):
            for c in re.findall(r"n == '(\w+)'", cond): out[c] = ret
        return out
    bd = rows(func_body(src, r'static Name BD\(Weapon w\)'))
    ex = rows(func_body(src, r'static Name Exact\(Weapon w\)'))
    return bd, ex

def parse_set_muzzle(src):
    body = func_body(src, r'static Vector3 Muzzle\(Weapon w\)')
    own, alias = [], {}
    for cond, f, l, u in re.findall(r"if \(([^)]*\)?[^)]*)\)\s*return \(([-\d.]+), ([-\d.]+), ([-\d.]+)\);", body):
        v = (float(f), float(l), float(u))
        if cond.strip() == '!w': continue
        m = re.match(r"\s*w is '(\w+)'\s*$", cond)
        if m: own.append((m.group(1), v)); continue
        m = re.match(r"\s*RSQ_Alias\.BD\(w\) == '(\w+)'\s*$", cond)
        if m: alias[m.group(1)] = v; continue
        m = re.match(r"\s*n == '(\w+)'\s*$", cond)
        if m: alias[m.group(1)] = v; continue
        sys.exit('gen_sets: muzzle.zs row not understood: if (%s)' % cond)
    b = re.search(r'static Vector3 Bore\(Weapon w\).*?return \(([-\d.]+), ([-\d.]+), ([-\d.]+)\);\s*\n\t}', src, re.S)
    bore = tuple(float(x) for x in b.groups())
    return own, alias, bore

def parse_bdbore():
    src = open(os.path.join(ROOT, 'zscript', 'rsqls', 'bdbore.zs'), encoding='latin-1').read()
    rows = {}
    for a, b, f, l, u in re.findall(r"if \((?:n == '(\w+)'|KindOf\(w, (?:a, )?'(\w+)'\))\) return true, ([-\d.]+), ([-\d.]+), ([-\d.]+);", src):
        rows.setdefault(a or b, (float(f), float(l), float(u)))
    yaw = float(re.search(r'BORE_YAW = ([-\d.]+)', src).group(1)); pitch = float(re.search(r'BORE_PITCH = ([-\d.]+)', src).group(1))
    return rows, yaw, pitch

def parse_muzzles():
    src = open(os.path.join(ROOT, 'zscript', 'rsqls', 'muzzles.zs'), encoding='latin-1').read()
    cl = re.search(r'CLASSES\[\] = \{(.*?)\};', src, re.S).group(1)
    s = re.findall(r'"([^"]*)"', cl)
    rows = [(s[i], int(s[i + 1]), int(s[i + 2]), s[i + 3].split()) for i in range(0, len(s), 4)]
    pl = [float(x) for x in re.findall(r'[-\d.]+', re.search(r'PLACE\[\] = \{(.*?)\};', src, re.S).group(1))]
    place = [pl[i:i + 10] for i in range(0, len(pl), 10)]
    nlen = int(re.search(r'const NLEN = (\d+);', src).group(1))
    return rows, place, nlen

def ready_frames(z):
    """-> {class: (parent, (sprite, frame) or None)} for every class the set's zscript defines."""
    out = {}
    for n in z.namelist():
        if not n.lower().endswith('.zs'): continue
        t = z.read(n).decode('latin-1')
        for m in re.finditer(r'\nclass\s+(\w+)\s*(?::\s*(\w+))?', t):
            i = t.find('{', m.end())
            if i < 0: continue
            depth, j = 0, i
            while j < len(t):
                if t[j] == '{': depth += 1
                elif t[j] == '}':
                    depth -= 1
                    if depth == 0: break
                j += 1
            r = re.search(r'\n\s*Ready:[^\n]*\n\s*"?(\w{4})"?\s+(\w)', t[i:j])
            out[m.group(1)] = (m.group(2), (r.group(1).upper(), r.group(2).upper()) if r else None)
    return out

def ready_of(cls, rf):
    seen = set()
    while cls in rf and cls not in seen:
        seen.add(cls)
        par, r = rf[cls]
        if r: return r
        cls = par
    return None

def flu_to_hud(v): return (-v[1], v[2] - 5.0, -v[0] - 30.0)        # hand.zs HudPoint, backwards
def bore_hud(b): return G.norm((-b[1], b[2], -b[0]))

_KEEP = {}
def keep_find(pak, tag):
    """pak.get, every result kept alive: gen_beams caches mesh points by id(data), so a freed bytes object whose id
    is reused would hand back another mesh's points"""
    def find(path):
        k = (tag, path.lower())
        if k not in _KEEP: _KEEP[k] = pak.get(path)
        return _KEEP[k]
    find.tag = tag
    return find

_md5 = {}
def snap_sig(snap, find):
    h = []
    for mi, fn in sorted(snap['models'].items()):
        if not fn.strip(): continue
        path = (snap['path'].rstrip('/') + '/' + fn) if snap['path'] else fn
        k = (find.tag, path.lower())
        if k not in _md5:
            d = find(path)
            _md5[k] = hashlib.md5(d).hexdigest() if d else None
        h.append((mi, _md5[k], snap['frames'].get(mi, 0)))
    return (tuple(h), snap['scale'], snap['off'], round(snap['ang'], 4), round(snap['pit'], 4), round(snap['rol'], 4))

_built = {}
def place_frame(cls, sn, table, find, mesh_cache):
    """gen_beams.py main()'s basis() + place(), for one frame of one class: (muzzle q from the Offset, barrel d, note)"""
    mid = G.mesh_id(sn)
    key = (find.tag, cls.lower(), mid)
    if key not in _built:
        cands = {}
        for (c, s2, f2), sx in table.items():
            if c == cls.lower() and G.mesh_id(sx) == mid: cands.setdefault(G.pose_key(sx), sx)
        if not cands: cands[G.pose_key(sn)] = sn
        ref = max(cands.values(), key=lambda sx: (G.xlines(sx, find), -sx['frames'].get(0, 0)))
        _built[key] = (ref, G.measure(ref, find))
    ref, (qr, dr, nr) = _built[key]
    if qr is None: return None, None, nr
    if G.pose_key(ref) == G.pose_key(sn): return qr, dr, nr
    m = G.rigid(mesh_cache, G.pose_key(ref), ref, G.pose_key(sn), sn, find, dr)
    if m is None: return G.measure(sn, find)
    R, tr, res = m
    d = G.norm(tuple(float(x) for x in R @ np.array(dr)))
    if res <= G.RIGID_RES: return tuple(float(x) for x in R @ np.array(qr) + tr), d, nr
    q, d, n = G.measure(sn, find, d)
    return q, d, n

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--bd', help="BD22 VR Reloaded's pk3: compare the aliased frames' MODELDEF snapshots")
    ap.add_argument('--dry', action='store_true')
    ap.add_argument('sets', nargs='+')
    a = ap.parse_args()

    bdrows, place, nlen = parse_muzzles()
    bore_rows, BYAW, BPITCH = parse_bdbore()
    rows_of = {}
    for c, pi, mir, fr in bdrows:
        rows_of.setdefault(c.lower(), []).append((pi, mir, fr))
    bd_find = bd_table = None
    if a.bd:
        bdp = [G.Pak(a.bd)]
        bd_table = G.read_modeldefs(bdp)
        bd_find = keep_find(bdp[0], 'BD')

    alias_out, own_out, report = [], [], []
    own_place, own_rows, sprites = [], [], []
    for sp in a.sets:
        setname = os.path.splitext(os.path.basename(sp))[0]
        z = zipfile.ZipFile(sp)
        bd, ex = parse_alias(read_text(z, 'zscript/rsq/alias.zs'))
        own, salias, bore = parse_set_muzzle(read_text(z, 'zscript/rsq/muzzle.zs'))
        yaw = math.degrees(math.atan2(bore[1], bore[0])); pitch = math.degrees(math.asin(bore[2]))
        if abs(yaw - BYAW) > BORE_TOL or abs(pitch - BPITCH) > BORE_TOL:
            sys.exit('gen_sets: %s fires down bore yaw %.4f pitch %.4f, bdbore.zs has %.4f %.4f' % (setname, yaw, pitch, BYAW, BPITCH))
        for k, v in salias.items():
            bv = bore_rows.get(k)
            if bv is None or max(abs(x - y) for x, y in zip(v, bv)) > 0.005:
                sys.exit('gen_sets: %s muzzle row %s %s, bdbore.zs has %s' % (setname, k, v, bv))
        report.append('%s: %d guns aliased, bore yaw %.4f pitch %.4f (= bdbore.zs), %d muzzle rows checked against bdbore.zs, own rows: %s'
                      % (setname, len(bd), yaw, pitch, len(salias), ', '.join('%s F %.2f L %.2f U %.2f' % (c, *v) for c, v in own) or 'none'))
        for c, v in own:
            own_out.append((c, v, setname))

        pk = [G.Pak(sp)]
        table = G.read_modeldefs(pk)
        find = keep_find(pk[0], setname)
        rf = ready_frames(z)
        mesh_cache = {}
        for cls in sorted(bd):
            bdn, exn = bd[cls], ex.get(cls, bd[cls])
            beam = exn if exn.lower() in rows_of else (bdn if bdn.lower() in rows_of else '')
            r = ready_of(cls, rf)
            note = ''
            ownbeam = False
            if cls not in rf:
                note = 'alias.zs names it, the set defines no such class: never loaded (BD22 rows of %s, unchecked)' % (beam or bdn)
            elif not beam:
                note = 'no BD22 beam rows for %s (melee or unmeasured): no beam' % bdn
            elif not r:
                note = 'no Ready frame found in its zscript: BD22 rows of %s used unchecked' % beam
            else:
                snap = table.get((cls.lower(), r[0], r[1]))
                code = '%s%d' % (r[0], ord(r[1]) - 65)
                row = [x for x in rows_of[beam.lower()] if code in x[2]]
                if not snap:
                    note = 'no model for %s: BD22 rows of %s used unchecked' % (code, beam)
                elif not row:
                    note = 'its Ready frame %s is not in %s rows: BD22 rows used unchecked' % (code, beam)
                else:
                    q, d, mn = place_frame(cls, snap, table, find, mesh_cache)
                    p = place[row[0][0]]
                    off = G.offset_hud(snap)
                    absq = G.add(off, q)
                    babs = (p[0] + p[3], p[1] + p[4], p[2] + p[5])
                    dmm = 10 * math.sqrt(sum((x - y) ** 2 for x, y in zip(absq, babs)))
                    ddeg = math.degrees(math.acos(max(-1, min(1, G.dot(d, p[6:9])))))
                    note = 'Ready %s: drawn muzzle %.1f mm, barrel %.2f deg from %s placement %d' % (code, dmm, ddeg, beam, row[0][0])
                    if dmm > REUSE_MM or ddeg > REUSE_DEG:
                        ownbeam = True
                        note += ' -> OWN placement'
                    if bd_table is not None:
                        same = tot = 0
                        bcls = beam.lower()
                        for (c2, s2, f2), sn in table.items():
                            if c2 != cls.lower(): continue
                            fc = '%s%d' % (s2, ord(f2) - 65)
                            if not any(fc in x[2] for x in rows_of[bcls]): continue
                            bs = bd_table.get((bcls, s2, f2))
                            tot += 1
                            if bs and snap_sig(bs, bd_find) == snap_sig(sn, find): same += 1
                        note += '; %d/%d of its beam frames drawn exactly as BD22 VR draws %s' % (same, tot, beam)
            if ownbeam:
                # THE SHOT LINE from the set's own muzzle row (a class of its own fires from its own muzzle), else the
                # BD22 row its alias picks; the beam starts on that line level with the drawn muzzle's face.
                ov = next((v for c, v in own if c == cls or rf.get(cls, (None,))[0] == c), None)
                fv = ov if ov else bore_rows.get(bdn)
                b = bore_hud(bore)
                S = flu_to_hud(fv)
                t = G.dot(G.sub(absq, S), b)
                start = G.add(S, G.mul(b, t))
                perp = math.sqrt(max(0.0, sum(x * x for x in G.sub(absq, start))))
                key = (tuple(round(x, 3) for x in off), tuple(round(x, 3) for x in start), tuple(round(x, 5) for x in b))
                if key not in [k for k, *_ in own_place]:
                    own_place.append((key, off, G.sub(start, off), b, cls))
                j = [k for k, *_ in own_place].index(key)
                # the frames that draw it: every frame of the class whose gun sits rigidly on the rest pose
                frames = []
                pk0 = G.pose_key(snap)
                for (c2, s2, f2), sn in sorted(table.items()):
                    if c2 != cls.lower(): continue
                    fc = '%s%d' % (s2, ord(f2) - 65)
                    if G.mesh_id(sn)[:2] != G.mesh_id(snap)[:2]:
                        continue    # another mesh (a hand, a magazine alone): not this gun
                    m = G.rigid(mesh_cache, pk0, snap, G.pose_key(sn), sn, find, d)
                    if m is None or m[2] > G.RIGID_RES: continue
                    R, tr, res = m
                    q2 = tuple(float(x) for x in R @ np.array(q) + tr)
                    d2 = G.norm(tuple(float(x) for x in R @ np.array(d)))
                    dq = G.sub(G.add(G.offset_hud(sn), q2), absq)
                    along = G.dot(dq, d)
                    pp = math.sqrt(max(0.0, G.dot(dq, dq) - along * along))
                    ang = math.degrees(math.acos(max(-1.0, min(1.0, G.dot(d2, d)))))
                    if ang <= G.ANGLE_TOL and pp <= G.PERP_TOL and abs(along) <= G.ALONG_TOL:
                        frames.append(fc)
                own_rows.append((cls, j, 1 if snap['scale'][0] < 0 else 0, sorted(set(frames)), setname))
                note += '; beam on the shot line (from F %.2f L %.2f U %.2f), %.1f mm from the drawn muzzle face centre, %d frames' % (fv[0], fv[1], fv[2], perp * 10, len(set(frames)))
                beam = ''
            alias_out.append((cls, setname, bdn, exn, beam))
            report.append('  %-28s -> BD %-18s exact %-22s beam %-22s %s' % (cls, bdn, exn, beam or ('(own)' if ownbeam else '(none)'), note))

    for c, v, s in own_out:
        report.append('own shot row: %s (and its subclasses) F %.2f L %.2f U %.2f (%s muzzle.zs)' % (c, v[0], v[1], v[2], s))
    nf = len(own_place) * nlen
    report.append('own beam placements: %d -> %d sprite frames (%s%s.. ), rods %d' % (len(own_place), nf, SPRITE_PREFIX, '00', nf))
    print('\n'.join(report))
    if a.dry: return

    # ---- the rods and VOXELDEF.sets ----
    bdir = os.path.join(ROOT, 'models', 'rsqls', 'beam')
    for f in os.listdir(bdir):
        if f.startswith('s') and f.endswith('.kvx'): os.remove(os.path.join(bdir, f))
    vd = ['// GENERATED by tools/gen_sets.py -- edit that, not this. The weapon sets\' own beam placements (a gun whose',
          '// drawn muzzle is off every BD22 placement), as VOXELDEF.txt: one rod per (placement, length), sprites %s..' % SPRITE_PREFIX, '']
    for j, (key, off, q0, d, cls) in enumerate(own_place):
        theta, phi = G.rod_angles(d)
        t = G.mul(G.Ry(-theta, G.Rx(-phi, q0)), 1.0 / G.BEAM_S)
        pivot = (-t[0], t[2] + 0.5, t[1] + 0.5)
        vd.append('// set placement %d (%s): muzzle %.2f %.2f %.2f cm from Offset %.2f %.2f %.2f; yaw %.3f, pitch %.3f (layer y %.2f)'
                  % (j, cls, q0[0], q0[1], q0[2], off[0], off[1], off[2], theta, phi, -4 * phi))
        for k, L in enumerate(G.LENGTHS):
            g = j * nlen + k
            spr = SPRITE_PREFIX + G.b36(g // 26)
            if spr not in sprites: sprites.append(spr)
            fn = 's%02dk%02d.kvx' % (j, k)
            G.write_kvx(os.path.join(bdir, fn), max(1, int(round(L / G.BEAM_S))), pivot)
            vd.append('%s%s = "models/rsqls/beam/%s" { Scale = %.4f AngleOffset = %.4f XOffset = %.4f YOffset = %.4f ZOffset = %.4f OverridePalette }'
                      % (spr, chr(65 + g % 26), fn, G.BEAM_S, -theta, off[0], off[2], off[1]))
    open(os.path.join(ROOT, 'VOXELDEF.sets'), 'w').write('\n'.join(vd) + '\n')

    # ---- sets.zs ----
    zs = ['// GENERATED by tools/gen_sets.py from: ' + ', '.join(os.path.basename(s) for s in a.sets) + ' -- do not edit.',
          '// THE WEAPON SETS (WoS Reloaded, GNRC Reloaded): their guns, by name, resolved to BD22\'s barrel rows. Each set\'s',
          '// own RSQ_Alias (alias.zs) copied here: the laser cannot call it (the same class name in every set, and no set is',
          '// always loaded), so it reads this. A class that is not loaded never matches: every set lives here at once.',
          'class RSQLS_Sets abstract', '{',
          '\t// class, set, BD22 gun (RSQ_Alias.BD), BD22 class by exact copy (RSQ_Alias.Exact: an off-hand copy is BD22\'s',
          '\t// off-hand copy), the class whose beam rows (muzzles.zs) it draws ("" = its own rows below, or no beam)',
          '\tstatic const String ALIAS[] = {']
    zs += ['\t\t"%s", "%s", "%s", "%s", "%s",' % r for r in alias_out]
    zs[-1] = zs[-1].rstrip(',')
    zs += ['\t};',
           '\t// a gun the set fires from a muzzle of its own (muzzle.zs `w is X`; X and its subclasses): F L U cm, down the',
           '\t// one bore every set shares with BD22 (checked: bdbore.zs BORE_YAW / BORE_PITCH)',
           '\tstatic const String OWN[] = { %s };' % ', '.join('"%s"' % c for c, v, s in own_out) if own_out else '\tstatic const String OWN[] = { "" };',
           '\tstatic const double OWN_FLU[] = { %s };' % ', '.join('%.2f, %.2f, %.2f' % v for c, v, s in own_out) if own_out else '\tstatic const double OWN_FLU[] = { 0, 0, 0 };',
           '\t// own beam rows, as RSQLS_Muzzles.CLASSES: class, placement (in PLACE below; beam.zs numbers them after',
           '\t// RSQLS_Muzzles\' own), mirrored, frames that draw it',
           '\tstatic const String CLASSES[] = {']
    if own_rows:
        zs += ['\t\t"%s", "%d", "%d", "%s",' % (c, j, m, ' '.join(fr)) for c, j, m, fr, s in own_rows]
        zs[-1] = zs[-1].rstrip(',')
    else:
        zs.append('\t\t"", "0", "0", ""')
    zs += ['\t};', '\t// per own placement, as RSQLS_Muzzles.PLACE: turning point, muzzle from it, barrel, layer y', '\tstatic const double PLACE[] = {']
    if own_place:
        for key, off, q0, d, cls in own_place:
            th, ph = G.rod_angles(d)
            zs.append('\t\t%.4f, %.4f, %.4f,  %.4f, %.4f, %.4f,  %.6f, %.6f, %.6f,  %.4f,' % (tuple(off) + tuple(q0) + tuple(d) + (-4 * ph,)))
        zs[-1] = zs[-1].rstrip(',')
    else:
        zs.append('\t\t0, 0, 0, 0, 0, 0, 0, 0, -1, 0')
    zs += ['\t};', '\tstatic const String SPRITES[] = { %s };' % (', '.join('"%s"' % s for s in sprites) or '"TNT1"'), '',
           '\tstatic clearscope int Row(Weapon w)', '\t{', '\t\tif (!w) return -1;', '\t\tString n = w.GetClassName();',
           '\t\tfor (int i = 0; i < RSQLS_Sets.ALIAS.Size(); i += 5) if (RSQLS_Sets.ALIAS[i] ~== n) return i;', '\t\treturn -1;', '\t}',
           '\t// RSQ_Alias.BD: the BD22 gun a set gun stands for; \'None\' for any other gun', '\tstatic clearscope Name BD(Weapon w)', '\t{',
           '\t\tint i = Row(w);', '\t\tName n = \'None\';', '\t\tif (i >= 0) n = Name(RSQLS_Sets.ALIAS[i + 2]);', '\t\treturn n;', '\t}',
           '\t// RSQ_Alias.Exact for a set gun; any other gun: its own class name', '\tstatic clearscope Name Exact(Weapon w)', '\t{',
           '\t\tif (!w) return \'None\';', '\t\tint i = Row(w);', '\t\tName n = w.GetClassName();', '\t\tif (i >= 0) n = Name(RSQLS_Sets.ALIAS[i + 3]);', '\t\treturn n;', '\t}',
           '\t// the class whose BD22 beam rows a set gun draws ("" none / its own)', '\tstatic clearscope String BeamOf(String cls)', '\t{',
           '\t\tfor (int i = 0; i < RSQLS_Sets.ALIAS.Size(); i += 5) if (RSQLS_Sets.ALIAS[i] ~== cls) return RSQLS_Sets.ALIAS[i + 4];', '\t\treturn "";', '\t}',
           '\tstatic clearscope String SetOf(Weapon w)', '\t{', '\t\tint i = Row(w);', '\t\treturn i >= 0 ? RSQLS_Sets.ALIAS[i + 1] : "";', '\t}',
           '\t// (found, F, L, U): the set\'s own muzzle row for this gun', '\tstatic clearscope bool, double, double, double OwnMuzzle(Weapon w)', '\t{',
           '\t\tif (!w) return false, 0, 0, 0;',
           '\t\tfor (int i = 0; i < RSQLS_Sets.OWN.Size(); i++)', '\t\t{', '\t\t\tif (RSQLS_Sets.OWN[i] == "") continue;', '\t\t\tclass<Actor> k = RSQLS_Sets.OWN[i];',
           '\t\t\tif (k && (w is k)) return true, RSQLS_Sets.OWN_FLU[i * 3], RSQLS_Sets.OWN_FLU[i * 3 + 1], RSQLS_Sets.OWN_FLU[i * 3 + 2];', '\t\t}',
           '\t\treturn false, 0, 0, 0;', '\t}', '}', '',
           '// every own rod\'s sprite frame named in a state (VOXELDEF takes only a sprite some state names); only the frames used',
           'class RSQLS_SetRods : Actor', '{', '\tStates', '\t{', '\tSpawn: TNT1 A -1; Stop;', '\tRods:']
    total = len(own_place) * nlen
    for i, s in enumerate(sprites):
        n = min(26, total - i * 26)
        zs.append('\t\t%s %s -1;' % (s, ''.join(chr(65 + k) for k in range(n))))
    if not sprites: zs.append('\t\tTNT1 A -1;')
    zs += ['\t\tStop;', '\t}', '}', '']
    open(os.path.join(ROOT, 'zscript', 'rsqls', 'sets.zs'), 'w').write('\n'.join(zs))

    t = ['SETS -- GENERATED by tools/gen_sets.py. The weapon sets\' guns resolved to BD22\'s barrel rows (beam: muzzles.zs;',
         'shot line: bdbore.zs), and the guns that need rows of their own.', ''] + report + ['']
    for j, (key, off, q0, d, cls) in enumerate(own_place):
        t.append('set placement %d (%s): Offset %.3f %.3f %.3f, muzzle from it %.3f %.3f %.3f, barrel %.5f %.5f %.5f (HUD frame, cm)'
                 % ((j, cls) + tuple(off) + tuple(q0) + tuple(d)))
    for c, j, m, fr, s in own_rows:
        t.append('own row %-24s set placement %d, %d frames: %s' % (c, j, len(fr), ' '.join(fr)))
    open(os.path.join(ROOT, 'docs', 'SETS.txt'), 'w').write('\n'.join(t) + '\n')
    print('wrote sets.zs, VOXELDEF.sets (%d rods, %d sprite frames), docs/SETS.txt' % (total, total))

if __name__ == '__main__':
    main()
