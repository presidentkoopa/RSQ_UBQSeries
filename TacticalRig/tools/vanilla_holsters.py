#!/usr/bin/env python3
"""vanilla_holsters.py -- vanilla Doom's guns on the body, in BD22 VR's holstered meshes (tool only; never ships).

The owner, 11-04 18:16 (BUGS_0.99a item 44): "Assume vanilla Doom has Pistol, Shotgun, SSG, Chaingun, RPG, Plasma, BFG.
We use the same holstered meshes for vanilla as we do for BD." The rig draws a stored gun only when RSQTRFIT measures it
(rig.zs DrawMarkers), and draws it by borrowing a class's MODELDEF (rig.zs RSQTR_Icon.Wear: A_ChangeModel). Brutal Doom's
guns borrow BD22 VR's own MODELDEF, which is not loaded with vanilla Doom, so this tool gives the rig its own copy of
each mesh it needs, cut to the one frame the rig wears:

  vanilla class   BD22 gun whose holstered mesh it wears (brutal22test6's own replacement of it: actors/Weapons
                  *SpawnerReplacer -> *Spawner, e.g. ChaingunSpawner spawns Minigun)
  Pistol          BrutalPistol
  Shotgun         Shot_Gun
  SuperShotgun    SSG
  Chaingun        Minigun
  RocketLauncher  Rocket_Launcher
  PlasmaRifle     Plasma_Gun
  BFG9000         BIG_FUCKING_GUN
  Chainsaw        Chain_saw

For each: the BD gun's RSQTRFIT row names the sprite frame worn (its Ready frame: the model you hold); that frame's MODELDEF
parts are read from the pk3s given (later wins, as the engine does), each part's mesh is cut to that one frame (the
frame blocks of the MD3 only, as Melee/tools/md3_frames.py does) and written with its skin to models/rsqtr/vanilla/, a
holder class RSQTR_VH_<vanilla> is given that MODELDEF (same scale, offsets and rotations; sprite RTGN A, the rig's carrier
frame), and the same measurement measure_pickups.py --held makes is run on it (its functions, imported) so the row is
the measured mesh. No flips: the held table is written without them (a held model points along -x by construction;
RSQTRFIT's BD rows, e.g. Chain_saw -180, carry none).

Writes, between the markers it owns:  RSQTRFIT.txt (VANILLA rows), MODELDEF.txt (VANILLA blocks).
The holder classes are zscript/rsqtr/vanilla.zs (by hand: one line each).

Usage: vanilla_holsters.py <pk3> [<pk3> ...]   (load order: brutal22test6.pk3 03_BD22_VR-Reloaded_*.pk3)
"""
import math, os, re, struct, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import measure_pickups as mp

ROOT = os.path.dirname(HERE)
MAP = [('Pistol', 'BrutalPistol'), ('Shotgun', 'Shot_Gun'), ('SuperShotgun', 'SSG'), ('Chaingun', 'Minigun'),
       ('RocketLauncher', 'Rocket_Launcher'), ('PlasmaRifle', 'Plasma_Gun'), ('BFG9000', 'BIG_FUCKING_GUN'),
       ('Chainsaw', 'Chain_saw')]
BEGIN = '// ---- VANILLA (tools/vanilla_holsters.py; do not edit by hand) ----'
END = '// ---- END VANILLA ----'

def md3_one_frame(d, keep):
    """An MD3 with only frame `keep` (Melee/tools/md3_frames.py's cut: geometry, UVs, triangles, shaders copied byte for byte)."""
    HDR = '<4si64siiiiiiiii'
    ident, ver, name, flags, nf, nt, ns, nsk, ofr, ota, osu, oend = struct.unpack(HDR, d[:108])
    assert ident == b'IDP3'
    keep = min(max(keep, 0), nf - 1)
    fr = d[ofr + keep * 56: ofr + (keep + 1) * 56]
    tg = d[ota + keep * nt * 112: ota + (keep + 1) * nt * 112]
    out_s = b''
    o = osu
    for s in range(ns):
        sh = struct.unpack('<4s64siiiiiiiiii', d[o:o + 108])
        _, sname, sflags, snf, nsh, nv, ntri, otri, osh, ost, oxyz, oe = sh
        body = d[o:o + oe]
        assert otri >= 108 and osh >= 108 and ost >= 108 and max(otri, osh, ost) < oxyz
        k = min(keep, snf - 1)
        xyz = body[oxyz + k * nv * 8: oxyz + (k + 1) * nv * 8]
        out_s += struct.pack('<4s64siiiiiiiiii', b'IDP3', sname, sflags, 1, nsh, nv, ntri, otri, osh, ost, oxyz, oxyz + len(xyz)) + body[108:oxyz] + xyz
        o += oe
    nofr = 108; nota = nofr + len(fr); nosu = nota + len(tg)
    return struct.pack(HDR, ident, ver, name, flags, 1, nt, ns, nsk, nofr, nota, nosu, nosu + len(out_s)) + fr + tg + out_s

def skins_of(body):
    """Skin <n> "<file>" lines of a MODELDEF block (measure_pickups reads only the geometry)."""
    out = {}
    for i in range(len(body) - 2):
        if body[i].lower() == 'skin':
            out[int(body[i + 1].strip('"'))] = body[i + 2].strip('"')
    return out

def splice(path, block):
    t = open(path, encoding='latin-1').read()
    if BEGIN in t:
        a = t.index(BEGIN); b = t.index(END) + len(END)
        t = t[:a].rstrip('\n') + '\n\n' + block + t[b:]
    else:
        t = t.rstrip('\n') + '\n\n' + block + '\n'
    open(path, 'w', encoding='latin-1').write(t)

def main():
    paks = [mp.Pak(p) for p in sys.argv[1:]]
    def find(path):
        for pk in reversed(paks):
            d = pk.get(path)
            if d is not None: return d
        return None
    table = {}
    for pk in paks:
        for low, real in sorted(pk.names.items()):
            base = low.rsplit('/', 1)[-1]
            if '/' in low or not base.startswith('modeldef'): continue
            for cls, body in mp.parse_modeldef(pk.z.read(real).decode('latin-1')):
                s = mp.block_settings(body)
                sk = skins_of(body)
                for spr, fr, mi, mf in s['frames']:
                    table.setdefault((cls.lower(), spr, fr), {})[int(mi)] = (s, mf, sk.get(int(mi)))
    fit = {}
    for line in open(os.path.join(ROOT, 'RSQTRFIT.txt'), encoding='latin-1'):
        t = line.split()
        if len(t) >= 11 and not line.startswith('//'): fit.setdefault(t[0].lower(), (t[9], int(t[10])))
    outdir = os.path.join(ROOT, 'models', 'rsqtr', 'vanilla')
    os.makedirs(outdir, exist_ok=True)
    fitrows, mdl, total = [], [], 0
    for van, bd in MAP:
        spr, frn = fit[bd.lower()]
        fr = chr(ord('A') + frn)
        parts = table.get((bd.lower(), spr, fr))
        if not parts: sys.exit('no MODELDEF for %s %s %s' % (bd, spr, fr))
        holder = 'RSQTR_VH_' + van
        blk = ['// %s wears %s\'s held mesh (%s %s, %s)' % (van, bd, spr, fr, ', '.join(sorted(set(
            (s['path'].rstrip('/') + '/' + s['models'][mi]) for mi, (s, mf, sk) in parts.items()))))]
        allpts = []
        for mi, (s, mf, sk) in sorted(parts.items()):
            fname = s['models'].get(mi)
            path = (s['path'].rstrip('/') + '/' + fname) if s['path'] else fname
            data = find(path)
            if data is None: sys.exit('missing ' + path)
            assert fname.lower().endswith('.md3'), fname
            one = md3_one_frame(data, int(mf))
            mname = '%s_%d.md3' % (van.lower(), mi)
            open(os.path.join(outdir, mname), 'wb').write(one); total += len(one)
            skin_line = ''
            if sk:
                spath = (s['path'].rstrip('/') + '/' + sk) if s['path'] else sk
                sd = find(spath)
                if sd is None: sys.exit('missing skin ' + spath)
                sname = '%s_%d%s' % (van.lower(), mi, os.path.splitext(sk)[1].lower())
                open(os.path.join(outdir, sname), 'wb').write(sd); total += len(sd)
                skin_line = '\tSkin %d "%s"' % (mi, sname)
            # the measurement, exactly as measure_pickups.py --held makes it
            pts = mp.md3_points(one, 0)
            sx, sy, sz = s['scale']
            pts = [(p[0] * sx, p[1] * sy, p[2] * sz) for p in pts]
            ox, oy, oz = s['offset']; oz += s['zoffset']
            off = (ox / sx if sx else 0, oy / sy if sy else 0, oz / sz if sz else 0)
            allpts += [tuple(q[i] + off[i] for i in range(3)) for q in (mp.rot(p, s['angle'], s['pitch'], s['roll']) for p in pts)]
            blk += ['Model %s' % holder, '{', '\tPath "models/rsqtr/vanilla"', '\tModel %d "%s"' % (mi, mname)]
            if skin_line: blk.append(skin_line)
            blk += ['\tScale %g %g %g' % s['scale'], '\tOffset %g %g %g' % s['offset'], '\tZOffset %g' % s['zoffset'],
                    '\tAngleOffset %g' % s['angle'], '\tPitchOffset %g' % s['pitch'], '\tRollOffset %g' % s['roll'],
                    '\tNoInterpolation', '\tFrameIndex RTGN A %d 0' % mi, '}']
        length, mz, s_lo, s_hi = mp.measure(allpts)
        if abs(mz[2]) > abs(mz[0]):
            if mz[2] < 0: mz = [-t for t in mz]
        elif mz[0] > 0: mz = [-t for t in mz]
        yaw = math.degrees(math.atan2(mz[1], mz[0]))
        pitch = -math.degrees(math.atan2(mz[2], math.hypot(mz[0], mz[1])))
        if abs(pitch) < 30 and abs(abs(yaw) - 180) < 30: yaw, pitch = 180.0, 0.0
        elif abs(pitch) < 30: yaw, pitch = 0.0, 0.0
        ctr = [(min(p[i] for p in allpts) + max(p[i] for p in allpts)) / 2 for i in range(3)]
        ext = sorted(max(p[i] for p in allpts) - min(p[i] for p in allpts) for i in range(3))
        length = max(length, ext[2])
        squat = ext[1] / ext[2] if ext[2] > 0 else 1.0
        fitrows.append('%s %.2f %.1f %.1f %s %.2f %.2f %.2f %.2f RTGN 0' % (van, length, -yaw, -pitch, holder, ctr[0], ctr[1], ctr[2], squat))
        mdl.append('\n'.join(blk))
        print('%-15s <- %-16s len %7.2f yaw %6.1f pitch %5.1f squat %.2f' % (van, bd, length, -yaw, -pitch, squat))
    srcs = ' -> '.join(os.path.basename(p) for p in sys.argv[1:])
    splice(os.path.join(ROOT, 'RSQTRFIT.txt'), '\n'.join([BEGIN, '// vanilla Doom\'s guns in BD22 VR\'s held meshes, measured from the rig\'s own one-frame copies (' + srcs + ')'] + fitrows + [END]))
    splice(os.path.join(ROOT, 'MODELDEF.txt'), '\n'.join([BEGIN, '// THE VANILLA GUNS ON THE BODY (owner 11-04): BD22 VR\'s held meshes, one frame each, carried by RSQTR_VH_* (vanilla.zs),', '// so the rig draws them with no Brutal Doom loaded. From ' + srcs + '.'] + mdl + [END]))
    print('meshes and skins written: %.2f MB in models/rsqtr/vanilla' % (total / 1048576.0))

if __name__ == '__main__':
    main()
