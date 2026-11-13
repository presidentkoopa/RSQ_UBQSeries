"""Build GNRC_Reloaded: Led's Generic Weapon Mod rebuilt in ZScript for VR, on BD22 VR's meshes, hands and reload systems
(WoS_Reloaded's pipeline, GNRC's guns).

    python3 tools/build.py            -> out/tree/ (the pack, unzipped) and out/BUILD_REPORT.txt
    python3 tools/build.py --pk3      -> also out/GNRC_Reloaded_<ver>.pk3, ONLY if out/suite.json says the full rig
                                         suite passed on this exact tree (tools/suite.py writes it). No pass, no pk3.

What goes in:
  src/                 the rebuild: zscript/gnrc/*.zs (the guns, the base, GNRC's non-weapon actors: tools/gen_gnrc.py)
  GNRC                 its assets only: sounds, sprites (not the barrels, keys or player), SNDINFO, DECALDEF, TEXTURES,
                       brightmaps, LANGUAGE. Never its DECORATE / ZSCRIPT / ACS / CVARINFO / MENUDEF / KEYCONF / MAPINFO.
  GNRC voxel pack      the pickups (VOX); the Beretta's pickup under RQGP (PIST is a HUD sprite)
  BD22 VR (lib.mdl, lib.zs_port)   the model blocks of each gun's BD22 mesh under this pack's class, and the VR systems
                       (hands, reload, pump, break-open, flick, dual, ballistics, casings, contact saw) with RSQ_Alias
                       naming which BD22 gun each RSQGW_ gun stands for."""
import glob, hashlib, json, os, re, shutil, struct, sys, zipfile, zlib
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(HERE, 'lib'))
import mdl, zs_port
BD = mdl.BD
# BD22 VR scripts this pack carries beyond the earlier port's set: the contact saw (as WoS_Reloaded)
zs_port.FILES = zs_port.FILES + ['rsq/pose.zs', 'rsvr/melee.zs']
GNRC = '/home/claude/src/gnrc'
VOX = '/home/claude/src/vox'
CFX, RSBS = '/home/claude/rs_combatfx/sounds', '/home/claude/rs_ballistics/sounds/rsb'
OUT = os.path.join(ROOT, 'out'); TREE = os.path.join(OUT, 'tree')
NAME, VERSION = 'GNRC_Reloaded', '0.1.0'

# ------------------------------------------------------------------------------------------------ the guns (PLAN.md)
# class -> the BD22 gun whose mesh / tables it uses
GUNS = {'RSQGW_Knuckle': 'Melee_Attacks', 'RSQGW_ModChainsaw': 'Chain_saw', 'RSQGW_Beretta': 'BrutalPistol', 'RSQGW_ARifle': 'Rifle',
        'RSQGW_Riotgun': 'Shot_Gun', 'RSQGW_DoubleSG': 'SSG', 'RSQGW_Minigun': 'Minigun', 'RSQGW_Rlauncher': 'Rocket_Launcher',
        'RSQGW_PlasRifle': 'Plasma_Gun', 'RSQGW_BFG9K': 'BIG_FUCKING_GUN'}
# the magazine hand reload (RSR_Guns): class -> row, magazine (Ammo2), reserve (Ammo1), racks. The BFG does not reload (owner).
RSR = {'RSQGW_Beretta': (2, 'RSQGW_PistolMag', 'RSQGW_PistolAmmo', True), 'RSQGW_ARifle': (1, 'RSQGW_RifleMag', 'RSQGW_RifleAmmo', True),
       'RSQGW_Minigun': (17, 'RSQGW_MinigunMag', 'RSQGW_Nato', False), 'RSQGW_Rlauncher': (9, 'RSQGW_RocketMag', 'RocketAmmo', False),
       'RSQGW_PlasRifle': (7, 'RSQGW_PlasmaMag', 'Cell', False)}
# dual wield: class, its magazine, magazine max, backpack max, menu name, on by default (as WoS_Reloaded: pistol and rifle
# on, the plasma gun and the shotguns off)
DUAL = [('RSQGW_Beretta', 'RSQGW_PistolMag', 11, 11, 'Pistol', True), ('RSQGW_ARifle', 'RSQGW_RifleMag', 31, 31, 'Assault Rifle', True),
        ('RSQGW_PlasRifle', 'RSQGW_PlasmaMag', 60, 60, 'Plasma Rifle', False), ('RSQGW_Riotgun', 'RSQGW_ShotgunMag', 8, 8, 'Riot Shotgun', False),
        ('RSQGW_DoubleSG', 'RSQGW_DBSGMag', 2, 2, 'Double-Barrel Shotgun', False)]
BDCOPY = {'BrutalPistol': 'RSQ_Off_BrutalPistol', 'Rifle': 'RSQ_Off_Rifle', 'Plasma_Gun': 'RSQ_Off_Plasma_Gun',
          'Shot_Gun': 'RSQ_Off_Shot_Gun', 'SSG': 'RSQ_Off_SSG'}
PICKUPS = {'RQGP', 'PUNP', 'CSAW', 'RIFL', 'RIOB', 'DBBL', 'MNIG', 'LAWN', 'PLAS', 'BFUG'}	# world sprites (voxels), not HUD frames
FISTS = 'RSQGW_Knuckle'
HELPERS = ['RSQ_GunSide', 'RSQ_Hands', 'RSR_GunParts', 'RSR_DroppedMag', 'RSP_DroppedShell', 'RSM_SpentCase', 'RSB_GunParts', 'RSB_Round', 'RSQ_Debris', 'RSQ_Bullet']

REPORT = []
def note(*a): REPORT.append(' '.join(str(x) for x in a))
def rd(p, enc='latin-1'): return open(p, encoding=enc).read()
def wr(rel, txt):
    p = os.path.join(TREE, rel); os.makedirs(os.path.dirname(p), exist_ok=True); open(p, 'w', encoding='latin-1').write(txt)
def cp(src, rel):
    p = os.path.join(TREE, rel); os.makedirs(os.path.dirname(p), exist_ok=True); shutil.copyfile(src, p)
def cptree(src, rel): shutil.copytree(src, os.path.join(TREE, rel), dirs_exist_ok=True)

def set_case(t, func, row, value):
    m = re.search(r'static\s+[\w<>, ]+?\s+%s\(int i[^)]*\)\s*\{.*?\n\t\}' % func, t, re.S)
    if not m: raise SystemExit('set_case: no function ' + func)
    v, c = (value.split('\t//', 1) + [None])[:2]          # a trailing comment goes after the ';', never inside it
    body, n = re.subn(r'(case %d:\s*return )[^;]*;' % row, lambda k: k.group(1) + v + ';' + ('\t//' + c if c else ''), m.group(0))
    if n != 1: raise SystemExit('set_case: %s row %d hits %d' % (func, row, n))
    return t[:m.start()] + body + t[m.end():]

# ------------------------------------------------------------------------------------------------ the rebuild's own classes
def zs_classes():
    """{class: (parent, set((sprite, frame)) its States show)} for every class in src/zscript"""
    out = {}
    for p in sorted(glob.glob(os.path.join(ROOT, 'src/zscript/**/*.zs'), recursive=True)):
        t = re.sub(r'//[^\n]*', '', re.sub(r'/\*.*?\*/', '', rd(p), flags=re.S))
        heads = list(re.finditer(r'^class\s+(\w+)\s*(?::\s*(\w+))?', t, re.M))
        for k, h in enumerate(heads):
            body = t[h.end():heads[k + 1].start() if k + 1 < len(heads) else len(t)]
            fr = set()
            for m in re.finditer(r'^\s*"?([A-Z0-9_]{4})"?\s+"?([A-Z\[\]\\]+)"?\s+-?\d', body, re.M):
                if m.group(1) not in ('TNT1', '####'):
                    for f in m.group(2): fr.add((m.group(1), f))
            out[h.group(1)] = (h.group(2), fr)
    return out
def frames_of(C, cls):
    fr = set()
    while cls in C:
        fr |= C[cls][1]; cls = C[cls][0]
    return fr

# ------------------------------------------------------------------------------------------------ the dual-wield copies
def dual_zs(present):
    L = ['// GENERATED by tools/build.py: the off-hand version of each dual gun (zscript/rsq/dual.zs). Its own magazine; it lives',
         '// in the off hand only, reloads by its stock reload (RSQGW_Gun.Reload: InOffHand) and fires on the off trigger.', '']
    for cls, mag, mx, bmx, nice, on in DUAL:
        if cls not in present: continue
        L += ['class %sOff : Ammo' % mag, '{', '\tDefault', '\t{', '\t\tInventory.Amount 0;', '\t\tInventory.MaxAmount %d;' % mx,
              '\t\tAmmo.BackpackAmount 0;', '\t\tAmmo.BackpackMaxAmount %d;' % bmx, '\t\t+INVENTORY.IGNORESKILL', '\t}', '}', '',
              'class RSQ_Off_%s : %s' % (cls, cls), '{', '\tDefault', '\t{', '\t\tTag "Off-hand %s";' % nice, '\t\tWeapon.AmmoGive1 0;',
              '\t\tWeapon.AmmoGive2 0;', '\t\tWeapon.SelectionOrder 99999;', '\t\tWeapon.AmmoType2 "%sOff";' % mag,
              '\t\t+WEAPON.OFFHANDWEAPON', '\t\t-WEAPON.NOHANDSWITCH', '\t\t+WEAPON.CHEATNOTWEAPON', '\t}', '}', '']
    return '\n'.join(L)

def dualtable(D):
    arr = lambda vals: '{ ' + ', '.join(vals) + ' }'
    return '\n'.join(['// GENERATED by tools/build.py: this pack\'s dual wield table (BD22 VR\'s RSQ_DualTable, its guns)', 'class RSQ_DualTable play', '{',
          '\tconst COUNT = %d;' % len(D), '\tconst AXE = 99;\t// no dual axe here',
          '\tclearscope static Name Gun(int i)\n\t{\n\t\tstatic const Name v[] = %s;\n\t\treturn v[i];\n\t}' % arr("'%s'" % d[0] for d in D),
          '\tclearscope static Name Copy(int i)\n\t{\n\t\tstatic const Name v[] = %s;\n\t\treturn v[i];\n\t}' % arr("'RSQ_Off_%s'" % d[0] for d in D),
          '\tstatic Name Mag(int i)\n\t{\n\t\tstatic const Name v[] = %s;\n\t\treturn v[i];\n\t}' % arr("'%sOff'" % d[1] for d in D),
          '\tstatic int MagMax(int i)\n\t{\n\t\tstatic const int v[] = %s;\n\t\treturn v[i];\n\t}' % arr(str(d[2]) for d in D),
          '\tstatic Name CVarName(int i)\n\t{\n\t\tstatic const Name v[] = %s;\n\t\treturn v[i];\n\t}' % arr("'rsq_dual_%d'" % k for k in range(len(D))),
          '\tstatic String Nice(int i)\n\t{\n\t\tstatic const String v[] = %s;\n\t\treturn v[i];\n\t}' % arr('"%s"' % d[4] for d in D),
          '\t// a second one of a gun picked up: the pickup is the gun itself',
          '\tstatic int PickupGun(Name n)\n\t{\n' + ''.join("\t\tif (n == '%s') return %d;\n" % (d[0], k) for k, d in enumerate(D)) + '\t\treturn -1;\n\t}', '}', '',
          '// the Dual Wield key (KEYCONF: netevent rsq_dual): the held gun\'s off-hand version into the off hand, or the hands back',
          'class RSQ_DualKey : EventHandler', '{', '\toverride void NetworkProcess(ConsoleEvent e)', '\t{',
          '\t\tif (!(e.Name ~== "rsq_dual") || e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player] || !players[e.Player].mo)', '\t\t\treturn;',
          '\t\tRSQ_Dual.Toggle(players[e.Player].mo);', '\t}', '}', ''])

# ------------------------------------------------------------------------------------------------ main
def main(want_pk3):
    if os.path.isdir(TREE): shutil.rmtree(TREE)
    os.makedirs(TREE)
    C = zs_classes()
    present = [g for g in GUNS if g in C]
    missing = [g for g in GUNS if g not in C]
    note('guns written:', ' '.join(present))
    if missing: note('GUNS NOT WRITTEN YET:', ' '.join(missing))
    D = [d for d in DUAL if d[0] in present]

    # 1. the rebuild's own scripts and lumps
    for p in sorted(glob.glob(os.path.join(ROOT, 'src/**/*'), recursive=True)):
        if os.path.isfile(p): cp(p, os.path.relpath(p, os.path.join(ROOT, 'src')))
    wr('zscript/gnrc/dual.gen.zs', dual_zs(present))

    # 2. GNRC's assets (never its code)
    for p in glob.glob(os.path.join(GNRC, 'sounds', '**/*'), recursive=True):
        if os.path.isfile(p): cp(p, os.path.relpath(p, GNRC))
    for p in glob.glob(os.path.join(GNRC, 'sprites', '**/*'), recursive=True):
        rel = os.path.relpath(p, GNRC)
        if os.path.isfile(p) and not re.search(r'/(barrel|keys)/|^sprites/player/', rel): cp(p, rel)
    for p in glob.glob(os.path.join(GNRC, 'brightmaps', '**/*'), recursive=True) + glob.glob(os.path.join(GNRC, 'graphics', '**/*'), recursive=True):
        if os.path.isfile(p): cp(p, os.path.relpath(p, GNRC))
    for f, to in (('sndinfo.txt', 'SNDINFO.gnrc'), ('decaldef.txt', 'DECALDEF.gnrc'), ('language.txt', 'LANGUAGE.gnrc'), ('TEXTURES.txt', 'TEXTURES.gnrc'), ('credits.txt', 'CREDITS_GNRC.txt')):
        cp(os.path.join(GNRC, f), to)
    note('GNRC assets: sounds, sprites (no barrels, keys, player), SNDINFO, DECALDEF, LANGUAGE, TEXTURES, brightmaps')
    # GNRC's voxel pack: the pickups; the Beretta's on RQGP (PIST is BD22's pistol HUD sprite)
    vd = rd(os.path.join(VOX, 'voxeldef.txt'))
    # EMNG (GNRC's thrown empty minigun: the death animation, not carried) and MSTI (GNRC's split medikit, not a weapon):
    # no actor here shows them, and the engine refuses a voxel for a sprite no actor uses
    vd, nd = re.subn(r'(?is)^(emnga|mstia)\s*=\s*"\w+"\s*\{[^}]*\}\s*', '', vd, flags=re.M)
    if nd != 2: raise SystemExit('voxeldef: %d of 2 unused entries dropped' % nd)
    vd += '\n// tools/build.py: the Beretta\'s pickup sprite is RQGP (PIST is a HUD sprite name)\nrqgpa = "pista"\n{\n\tScale = 0.5\n\tDroppedSpin = 10\n\tPlacedSpin = 10\n}\n'
    wr('voxeldef.txt', vd)
    for p in glob.glob(os.path.join(VOX, 'voxels/*')): cp(p, 'voxels/' + os.path.basename(p))
    note('voxels: the GNRC voxel pack (%d), Beretta pickup on RQGP' % len(glob.glob(os.path.join(VOX, 'voxels/*'))))

    # 3. BD22 VR's model blocks under this pack's classes
    alias = {g: GUNS[g] for g in present}
    malias = dict(alias)
    for d in D: malias['RSQ_Off_' + d[0]] = BDCOPY[GUNS[d[0]]]
    lumps, files, keyed, sprites, miss = mdl.build(malias, HELPERS)
    if miss: raise SystemExit('model files missing: %s' % miss[:5])
    # the minigun's magazine, as WoS_Reloaded's Rotary Cannon (owner: "when we 'grab a magazine' I want to see a half sized voxel ammo box in my hand";
    # "if the chaingun drops an ammo box, recolor it brown or grey so it looks empty"): BD22's voxel ammo box as an MD3
    # (tools/ammobox_md3.py: 18 units long, half its pickup; its middle at the origin), in BD22 VR's own three blocks for
    # the minigun's magazine piece -- at the gun, in the off hand, dropped -- with BD22 VR's own placements, hooks and
    # hold, each block's Offset / ZOffset solved (port_gun.chain) so the box's middle is where the magazine piece's
    # middle was (Minigun_rsr.md3 surface 2, frame 4). The dropped one wears the empty skin.
    sys.path.insert(0, '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/tools/handfit/port')
    _argv = sys.argv; sys.argv = sys.argv[:1]
    import numpy as np, port_gun as pg
    sys.argv = _argv
    Pm = pg.raw(os.path.join(BD, 'models/bd/Minigun/Minigun_rsr.md3'), 4, [2]); Cm = (Pm.min(0) + Pm.max(0)) / 2
    def solve(scale, off, ao):
        want = pg.chain(scale, off, ao)(Cm[None, :])[0]
        f = lambda o: pg.chain(scale, o, ao)(np.zeros((1, 3)))[0]
        f0 = f((0, 0, 0)); J = np.stack([f(tuple(np.eye(3)[k])) - f0 for k in range(3)], 1)
        return np.linalg.solve(J, want - f0)
    BOXB = {('RSR_GunParts', 'RQCP'): ((-1, 1, 1), (-1.156, -5.106, -1.923), (3.854, 3.363, 10.974), 'ammoa.png', '\tNoInterpolation\n'),
            ('RSQ_Hands', 'RQCP'): ((-1, 1, 1), (0, 0, -5), (0, 0, 0), 'ammoa.png', '\tNoInterpolation\n'),
            ('RSR_DroppedMag', 'RQCW'): ((0.3468, 0.3468, 0.3468), (-21.527, 1.3567, 6.3229), (0, 0, 0), 'ammoa_empty.png', '\tUSEACTORPITCH\n\tUSEACTORROLL\n')}
    box = {}
    for key, (sc, off, ao, skin, tail) in BOXB.items():
        o = solve(sc, off, ao)
        box[key] = ('\tPath "models/rsqgw/ammobox"\n\tModel 0 "ammobox.md3"\n\tSkin 0 "%s"\n\tScale %.4f %.4f %.4f\n\tOffset %.3f %.3f 0.0\n\tZOffset %.3f\n'
                    % ((skin,) + tuple(sc) + tuple(o)) + ('\tAngleOffset %.3f\n\tPitchOffset %.3f\n\tRollOffset %.3f\n' % ao if any(ao) else '') + tail
                    + '\tFrameIndex %s A 0 0\n' % key[1])
    hit = set()
    def boxed(m):
        for (cls, spr), body in box.items():
            if m.group(1) == cls and re.search(r'FrameIndex\s+%s\s+A\s' % spr, m.group(2)):
                hit.add((cls, spr)); return 'Model %s\n{\n%s}' % (cls, body)
        return m.group(0)
    lumps['MODELDEF.rsr'] = re.sub(r'Model (\w+)\n\{(.*?)\n\}', boxed, lumps['MODELDEF.rsr'], flags=re.S)
    if len(hit) != 3: raise SystemExit('minigun ammo box: %d of 3 blocks replaced' % len(hit))
    for f in ('ammobox.md3', 'ammoa.png', 'ammoa_empty.png'): cp(os.path.join(ROOT, 'assets/ammobox', f), 'models/rsqgw/ammobox/' + f)
    note('Minigun magazine: BD22 voxel ammo box as an MD3 (18 units), in BD22 VR\'s three magazine blocks; dropped = empty skin')
    # Real Casing Models: BD22 VR's measured casings on GNRC's casing sprites (CAS1 9 mm, CAS2 12 ga, CAS3 rifle)
    CASE = {'RSQ_Case9mm': 'CAS1', 'RSQ_Case556': 'CAS3', 'RSQ_Case762': 'CAS3', 'RSQ_Hull12ga': 'CAS2'}
    def recase(m):
        body = re.sub(r'^[ \t]*FrameIndex[^\n]*\n?', '', m.group(3), flags=re.M).rstrip()
        return 'Model %s%s\n{%s\n%s\n}' % (m.group(1), m.group(2), body, '\n'.join('\tFrameIndex %s %s 0 0' % (CASE[m.group(1)], f) for f in 'ABCDEFGHIJKLMN'))
    lumps['MODELDEF.rsqcase'], nb = re.subn(r'Model (\w+)([^\n{]*)\n\{(.*?)\n\}', recase, rd(os.path.join(BD, 'MODELDEF.rsqcase')), flags=re.S)
    note('casing model blocks: %d' % nb)
    cptree(os.path.join(BD, 'models/rsq/casings'), 'models/rsq/casings')
    sprites |= {'CAS1', 'CAS2', 'CAS3'}
    for k, txt in lumps.items(): wr(k, txt)
    for rel in sorted(files): cp(os.path.join(BD, rel), rel)
    cptree(os.path.join(BD, 'models/rsq/fbx/tones'), 'models/rsq/fbx/tones')
    for f in ('models/rsq/LICENSE_RustedLegacy_MIT.txt', 'LICENSE_Dakka_WTFPL.txt'): cp(os.path.join(BD, f), f)
    # every frame a gun shows must be keyed on it (else it draws nothing in VR)
    for g in present + ['RSQ_Off_' + d[0] for d in D]:
        bad = sorted(x for x in frames_of(C, g if g in C else g[8:]) if x not in keyed.get(g, ()) and x[0] not in PICKUPS)
        if bad: note('NOT KEYED on %s: %s' % (g, ' '.join(a + b for a, b in bad)))

    # 4. BD22 VR's scripts, its gun names through RSQ_Alias
    g = zs_port.alias(zs_port.read('rsr/rsr_guns.bd.zs'))
    rows = {c: r for c, r in RSR.items() if c in present}
    idx = '\tclearscope static int Index(Weapon w)\n\t{\n\t\tif (!w)\n\t\t\treturn 0;\n\t\tName n = w.GetClassName();\n' + \
          ''.join("\t\tif (n == '%s' || n == 'RSQ_Off_%s')\treturn %d;\n" % (c, c, r[0]) for c, r in rows.items()) + '\t\treturn 0;\n\t}'
    g, n = re.subn(r'\tclearscope static int Index\(Weapon w\)\n\t\{.*?\n\t\}', lambda m: idx, g, count=1, flags=re.S); assert n == 1
    # Ballistics Stock: the hand reload plays each gun's own GNRC reload sounds (GNRC's reload states, in their order);
    # Low / Max keeps BD22 VR's row sounds (RS Combat FX / RS Ballistics through BD's names, SNDINFO.rsqfx). "" = none.
    OGSND = {  # row: (magazine out, magazine in, slide / bolt back, forward, magazine lands)
        2: ('weapons/pistol/cout', 'weapons/pistol/cin', 'weapons/pistol/snap', 'weapons/pistol/snap', ''),
        1: ('weapons/rifle/cout', 'weapons/rifle/cin', 'weapons/rifle/slap', 'weapons/rifle/click', ''),
        17: ('weapons/minig/chain', 'weapons/minig/reload', '', '', ''),
        9: ('weapons/rocket/out', 'weapons/rocket/in', '', '', ''),
        7: ('weapons/prifle/cout', 'weapons/prifle/cin', '', '', '')}
    og = ['// GENERATED by tools/build.py: the hand reload\'s sounds at Ballistics Stock (GNRC\'s own)', 'class RSQGW_OGSnd abstract', '{',
          '\t// k: 0 out, 1 in, 2 back, 3 forward, 4 lands. "-": no GNRC sound known for that row (the row\'s own plays)',
          '\tclearscope static String Get(int i, int k)', '\t{']
    for r, v in OGSND.items():
        og.append('\t\tif (i == %d)\t{ static const String s%d[] = { %s }; return s%d[k]; }' % (r, r, ', '.join('"%s"' % x for x in v), r))
    og += ['\t\treturn "-";', '\t}', '}', '']
    wr('zscript/gnrc/ogsnd.gen.zs', '\n'.join(og))
    for k, fn in enumerate(('SndOut', 'SndIn', 'SndBack', 'SndFwd', 'SndLand')):
        g, n = re.subn(r'(clearscope static String %s\(int i\)\n\t\{\n)' % fn,
                       lambda m: m.group(1) + '\t\tif (!RSQGW_FX.Enhanced())\t// this pack: Ballistics Stock -> GNRC\'s own reload sounds\n\t\t{\n\t\t\tString og = RSQGW_OGSnd.Get(i, %d);\n\t\t\tif (og != "-")\n\t\t\t\treturn og;\n\t\t}\n' % k, g, count=1)
        assert n == 1, fn
    for c, (row, mag, res, racks) in rows.items():
        g = set_case(g, 'Reserve', row, '"%s"' % res); g = set_case(g, 'MagAmmo', row, '"%s"' % mag)
        g = set_case(g, 'NoMag', row, '""'); g = set_case(g, 'ReloadToken', row, '""')
        g = set_case(g, 'ChargeToken', row, '"RSR_Charge"' if racks else '""')
        note('reload row %d %s: magazine %s, reserve %s%s' % (row, c, mag, res, ', racks' if racks else ''))
    if 'RSQGW_Riotgun' in present:      # the pump table's row 1 (the Shot_Gun mesh): the Riot Shotgun's tube and sounds
        PUMP = (('WaitLabels', '"RSP_LoadWait RSP_LoadWaitE RSP_P1Wait RSP_P2Wait"'), ('Loaded', '"RSQGW_ShotgunMag"'), ('MagAmmo', '"RSQGW_ShotgunMag"'),
                ('Reserve', '"Shell"'), ('Cap', '8'), ('SndBack', '"weapons/riotgun/bck"'), ('SndFwd', '"weapons/riotgun/fwd"'), ('SndShell', '"weapons/riotgun/load"'))
        note('pump row 1 RSQGW_Riotgun: tube RSQGW_ShotgunMag (8), reserve Shell, GNRC pump sounds')
    if 'RSQGW_DoubleSG' in present:     # the break-open table's row 1 (the SSG mesh)
        BRK = (('Loaded', '"RSQGW_DBSGMag"'), ('Reserve', '"Shell"'), ('Unloaded', '""'), ('ReloadToken', '""'), ('SndOpen', '"weapons/dbsg/opn"'))
        note('break-open row 1 RSQGW_DoubleSG: loaded RSQGW_DBSGMag, reserve Shell')
    patches = {
        # the Assault Rifle has no underbarrel (its alt is the burst switch): BD22 VR's launcher module never takes it
        'rsr/rsr_m203.zs': [("return w && RSQ_Alias.Exact(w) == 'Rifle';", "return false;\t// this pack: the Assault Rifle has no underbarrel", 1),
            ("if (n == 'Rifle') return 1;", "// this pack: the Assault Rifle has no underbarrel (BD22 VR: if (n == 'Rifle') return 1;)", 1),
            ("return w && (RSQ_Alias.Exact(w) == 'Rifle' || RSQ_Alias.Exact(w) == 'RSQ_Off_Rifle');", "return false;\t// this pack: the Assault Rifle has no underbarrel", 1)],
        'rsq/dual.zs': [("Name n = RSQ_Alias.Exact(w);", "Name n = w.GetClassName();", 2), ("off ? 'RSQ_Hands' : 'Melee_Attacks'", "off ? 'RSQ_Hands' : '%s'" % FISTS, 1),
            (re.compile(r"^(\t+)Silvergun\(mo, n\);", re.M), r"\1// (this pack has no Silvergun: BD22 VR's Silvergun(mo, n) is not called)", 1)],
        'rsq/dualhands.zs': [("Name cn = w ? w.GetClassName() : 'None';", "Name cn = w ? RSQ_Alias.BD(w) : 'None';", 1)],
        # Ballistics: BD22 VR's own gates, unchanged. Stock = GNRC's own look and sounds; Low / Max = RS Ballistics
        'rsq/ballistics.zs': [("e.Thing.player.ReadyWeapon.GetClassName()", "RSQ_Alias.BD(e.Thing.player.ReadyWeapon)", 1),
            ("tracer.player.ReadyWeapon.GetClassName()", "RSQ_Alias.BD(tracer.player.ReadyWeapon)", 1)],
        'rsq/flash.zs': [("String n = w.GetClassName();", "String n = RSQ_Alias.BD(w);", 1)],
        # rsq/flick.zs: BD22 VR's, unchanged but for the alias: it reloads a gun in each hand and a lone SSG
        'rsq/casings.zs': [(re.compile(r"Name n = c\.GetClassName\(\);"), "Name n = c.GetClassName();\n\t\t// this pack: GNRC's casings under the names BD22 VR's tables know\n\t\tif (n == 'RSQGW_9mmCasing') n = 'PistolCasing';\n\t\telse if (n == 'RSQGW_RifleCasing' || n == 'RSQGW_ChaingunCasing') n = 'EmptyBrass';\n\t\telse if (n == 'RSQGW_ShotgunCasing') n = 'ShotgunCasing';", 1),
            ("mo.player.ReadyWeapon ? mo.player.ReadyWeapon.GetClassName() : 'None'", "RSQ_Alias.BD(mo.player.ReadyWeapon)", 2),
            ("return t ? PlayerPawn(t.target) : null;", "if (t && PlayerPawn(t.target))\n\t\t\treturn PlayerPawn(t.target);\n\t\treturn multiplayer ? null : players[consoleplayer].mo;\t// this pack: GNRC's casings do not always carry their shooter", 1)],
        'rsr/vreload.zs': [("PlayerInt(mo.player, 'rsr_rig_pouch', 1) == 0", "PlayerInt(mo.player, 'rsr_pouch', 0) != 2\t/* this pack: New magazine from = Tactical Rig's pouch */", 1)],
    }
    # the contact saw only (as WoS_Reloaded): BD22 VR's melee reads no other weapon here, and each cut is the chainsaw's
    # own (RSQGW_SawCut, GNRC's saw damage)
    patches['rsvr/melee.zs'] = [
        (re.compile(r"(static int KindOf\(PlayerPawn mo\)\n\t\{\n\t\tlet p = mo\.player;\n\t\tif \(!p \|\| !p\.ReadyWeapon \|\| p\.PendingWeapon != WP_NOCHANGE \|\| mo\.health <= 0\)\n\t\t\treturn 0;\n).*?(\n\t\}\n)", re.S),
         r"\1\t\t// this pack: the chainsaw is the only weapon BD22 VR's melee reads (the contact saw)\n\t\treturn p.ReadyWeapon is 'RSQGW_ModChainsaw' ? SAW : 0;\2", 1),
        (re.compile(r"(static int KindOfOff\(PlayerPawn mo\)\n\t\{\n)"), r"\1\t\treturn 0;\t// this pack: no off-hand melee weapon (axe, pistol whip)\n", 1),
        ("Launch(mo, 'SawDamageHorizontal',", "Launch(mo, 'RSQGW_SawCut',", 1),
        ("RSQ_Alias.Exact(a) == 'BrutalAxe'", "a.GetClassName() == 'BrutalAxe'", 1)]
    zs_port.port(TREE, patches)
    for rel, rows_ in (('zscript/rsr/rsr_pump_guns.zs', PUMP if 'RSQGW_Riotgun' in present else ()), ('zscript/rsr/rsb_guns.zs', BRK if 'RSQGW_DoubleSG' in present else ())):
        if not rows_: continue
        bt = rd(os.path.join(TREE, rel))
        for fn, val in rows_: bt = set_case(bt, fn, 1, val)
        wr(rel, bt)
    wr('zscript/rsr/rsr_guns.bd.zs', g)
    al = ['// GENERATED by tools/build.py: which BD22 gun each RSQGW_ gun stands for. BD22 VR\'s tables (hands, muzzle, recoil',
          '// follow, reload geometry) are keyed by BD22\'s class names; this is the one place the two meet.',
          'class RSQ_Alias abstract', '{', '\tclearscope static Name BD(Weapon w)', '\t{', '\t\tif (!w)', "\t\t\treturn 'None';", '\t\tName n = w.GetClassName();']
    for k, v in alias.items(): al.append("\t\tif (n == '%s' || n == 'RSQ_Off_%s')\treturn '%s';" % (k, k, v))
    al += ["\t\treturn 'None';", '\t}', '', '\t// by exact class: an off-hand version is BD22 VR\'s off-hand version, not the gun',
           '\tclearscope static Name Exact(Weapon w)', '\t{', '\t\tif (!w)', "\t\t\treturn 'None';", '\t\tName n = w.GetClassName();'] + \
          ["\t\tif (n == 'RSQ_Off_%s')\treturn '%s';" % (d[0], BDCOPY[GUNS[d[0]]]) for d in D] + ['\t\treturn BD(w);', '\t}', '}', '',
           '// every sprite name the model definitions key, named once so MODELDEF knows them',
           'class RSQ_BDSprites : Actor', '{', '\tStates', '\t{', '\tSpawn:', '\t\tTNT1 A 0;'] + \
          ['\t\t"%s" A 0;' % s for s in sorted(sprites)] + ['\t\tStop;', '\t}', '}', '']
    wr('zscript/rsq/alias.zs', '\n'.join(al))
    cp(os.path.join(HERE, 'lib/stubs.zs'), 'zscript/rsq/stubs.zs')
    cp(os.path.join(HERE, 'lib/stubs_melee.zs'), 'zscript/rsq/stubs_melee.zs')
    wr('zscript/rsq/dualtable.zs', dualtable(D))
    own = sorted(os.path.relpath(p, os.path.join(ROOT, 'src')) for p in glob.glob(os.path.join(ROOT, 'src/zscript/**/*.zs'), recursive=True))
    inc = own + ['zscript/gnrc/dual.gen.zs', 'zscript/gnrc/ogsnd.gen.zs', 'zscript/rsq/alias.zs', 'zscript/rsq/stubs.zs', 'zscript/rsq/stubs_melee.zs', 'zscript/rsq/dualtable.zs'] + ['zscript/' + f for f in zs_port.FILES]
    wr('ZSCRIPT.zs', 'version "4.14"\n// %s %s: Led\'s Generic Weapon Mod rebuilt in ZScript for VR, on BD22 VR\'s meshes, hands and reload (RS_Brutal22WeaponsQ)\n' % (NAME, VERSION)
       + ''.join('#include "%s"\n' % i for i in inc))

    # 5. lumps
    H = ['RSVR_HandSync', 'RSQ_PoseHandler', 'RSVR_MeleeHandler', 'RSQ_Handler', 'RSR_ReloadHandler', 'RSB_Handler', 'RSP_Handler', 'RSK_M203Handler', 'RSQ_Muzzle', 'RSQ_HandTone',
         'RSA_Casings', 'RSQ_AmmoHud', 'RSQ_Flick', 'RSQ_Ballistics', 'RSQ_FlashHandler', 'RSQ_PlayerRounds', 'RSQ_ShotFX',
         'RSQ_Dual', 'RSQ_DualHands', 'RSQ_DualKey', 'RSQ_ScopeReal', 'RSQGW_KickKey']
    wr('MAPINFO.rsq', 'gameinfo\n{\n\tPlayerClasses = "RSQGW_Player"\n\tAddEventHandlers = %s\n}\n' % ', '.join('"%s"' % h for h in H))
    dc = ['user bool rsq_dual_start = true;\t// Start With Two Pistols'] + ['user bool rsq_dual_%d = %s;\t// dual %s' % (k, 'true' if d[5] else 'false', d[4]) for k, d in enumerate(D)]
    wr('CVARINFO.rsq', rd(os.path.join(HERE, 'lib/CVARINFO.base')) + '\n'.join(dc) + '\n')
    dm = ['', 'OptionMenu "RSQ_DualOptions"', '{', '\tTitle "DUAL OPTIONS"', '\tOption "Start With Two Pistols", "rsq_dual_start", "OnOff"'] + \
         ['\tOption "%s", "rsq_dual_%d", "OnOff"' % (d[4], k) for k, d in enumerate(D)] + ['}', '']
    wr('MENUDEF.rsq', rd(os.path.join(HERE, 'lib/MENUDEF.base')) + '\n'.join(dm))
    wr('KEYCONF.rsq', 'addkeysection "GNRC Reloaded VR" rsqgwvr\naddmenukey "Quick Kick" rsqgw_kickkey\nalias rsqgw_kickkey "netevent rsqgw_kick"\n'
       'addmenukey "Dual Wield" rsq_dualkey\nalias rsq_dualkey "netevent rsq_dual"\n')
    wr('SNDINFO.rsr', rd(os.path.join(BD, 'SNDINFO.rsr')) + "\n// the underbarrel launcher's sounds (BD22's names, Doom 2's own lumps)\nGrenadeLauncher/Open\tdsdbopn\nGrenadeLauncher/Close\tdsdbcls\nGrenadeLauncher/Load\tdsdbload\nWeapon/Empty\tdsswtchn\n"
       "\n// tools/build.py: a trigger on an empty gun (RSQGW_Gun.RSQGW_Empty): Doom 2's own click\nRSQGW/dry\tdsswtchn\n")
    cptree(os.path.join(BD, 'sounds/rsr'), 'sounds/rsr')
    cptree(os.path.join(BD, 'sounds/rsb'), 'sounds/rsb')
    for f in ('SURFACES.rsq', 'ANIMDEFS.rsq'): cp(os.path.join(BD, f), f)
    wr('SNDINFO.rsb', rd(os.path.join(BD, 'SNDINFO.rsq')))
    for f in sorted(os.listdir(os.path.join(BD, 'sprites'))):
        if f.startswith(('RSBM', 'RSDP')): cp(os.path.join(BD, 'sprites', f), 'sprites/' + f)
    # BD22 VR's reload-table sound names, from RS Combat FX (C) / RS Ballistics (B) (owner: "just use online repo rs ballistics or rs combat fx")
    FX = {'Pistol/Reload1': ['C:pistol/magout/bclipout.wav'], 'Pistol/Reload2': ['C:pistol/magin/bclipin.wav'], 'pistol/slide2': ['C:pistol/cycle/bslide2.wav'],
          'Rifle/Reload1': ['C:rifle/magout/RIFCL_OUT.ogg'], 'Rifle/Reload2': ['C:rifle/magin/RIFCL_IN.ogg'],
          'Rifle/Bolt1': ['C:shared/cycle/RCOCK.ogg'], 'Rifle/Bolt2': ['C:rifle/unsorted/RIFCL_CK.ogg'],
          'MP40/Reload1': ['C:chaingun/magout/mgclpout.wav'], 'MP40/Reload2': ['C:chaingun/magin/mgclpin.wav'],
          'MP40/Bolt1': ['C:pistol/cycle/bslide1.wav'], 'MP40/Bolt2': ['C:smg/lock/RAIFLOCK.ogg'],
          'Railgun/Reload1': ['C:plasma/magout/CELLOUT.ogg'], 'Railgun/Reload2': ['C:plasma/magin/CELLIN.ogg'],
          'Plasma/Reload1': ['C:plasma/magout/CELLOUT.ogg'], 'Plasma/Reload2': ['C:plasma/magin/CELLIN.ogg'],
          'rocket/reload1': ['C:launcher/unsorted/RL_MagPop.ogg'], 'rocket/reload2': ['C:launcher/unsorted/RL_MagPlace.ogg'],
          'weapons/largemagdrop': ['B:debris/metal_big/dsaounc%d.ogg' % k for k in range(1, 7)],
          'weapons/barrelpain': ['B:debris/metal_big/dsaounc%d.ogg' % k for k in range(1, 7)],
          'weapons/smallmagdrop': ['B:debris/metal/dsbounc%d.ogg' % k for k in range(1, 7)],
          'Melee/Swing': ['C:melee/unsorted/SWING%d.ogg' % k for k in range(1, 7)], 'GrenadeLauncher/Fire': ['C:launcher/fire/SGLFIRE.ogg']}
    si = ['// GENERATED by tools/build.py: BD22 VR\'s reload sound names, from RS Combat FX (C) and RS Ballistics (B)', '']
    for nm, srcs in FX.items():
        paths = []
        for sp in srcs:
            root, rel = (CFX, sp[2:]) if sp[0] == 'C' else (RSBS, sp[2:])
            dst = 'rsfx/' + ('cfx/' if sp[0] == 'C' else 'rsb/') + rel
            cp(os.path.join(root, rel), dst); paths.append(dst)
        if len(paths) == 1: si.append('%s\t"%s"' % (nm, paths[0]))
        else:
            si += ['%s_%d\t"%s"' % (nm, k + 1, p) for k, p in enumerate(paths)]
            si.append('$random %s { %s }' % (nm, ' '.join('%s_%d' % (nm, k + 1) for k in range(len(paths)))))
    wr('SNDINFO.rsqfx', '\n'.join(si) + '\n')
    # 6. a weapon is only picked up when its Ready frame has an image (Weapon.TryPickup -> ValidateSpriteFrame): every
    # model-keyed frame with no image in the pack gets a transparent 1x1 one (never over a real one)
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', 1, 1, 8, 6, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(b'\x00\x00\x00\x00\x00')) + chunk(b'IEND', b'')
    have = set()
    for r, d, fs in os.walk(TREE):
        if not os.path.relpath(r, TREE).lower().startswith('sprites'): continue
        for f in fs:
            b0 = os.path.splitext(f)[0].upper()
            if len(b0) >= 6: have.add((b0[:4], b0[4]))
            if len(b0) >= 8: have.add((b0[:4], b0[6]))
    for m in re.finditer(r'(?im)^\s*sprite\s+"?(\w{4})(\w)\w"?', rd(os.path.join(TREE, 'TEXTURES.gnrc'))): have.add((m.group(1).upper(), m.group(2).upper()))	# GNRC's TEXTURES sprites
    need = set()
    for mp in glob.glob(os.path.join(TREE, 'MODELDEF*')):
        for m in re.finditer(r'(?im)^\s*FrameIndex\s+"?(\S{4})"?\s+"?(\S)"?\s', rd(mp)): need.add((m.group(1).upper(), m.group(2).upper()))
    for c in present: need |= frames_of(C, c)
    made = 0
    for sp, fr in sorted(need):
        if (sp, fr) in have or not re.match(r'^[A-Z0-9_]{4}$', sp) or not fr.isalpha(): continue
        p = os.path.join(TREE, 'sprites/rsqblank', '%s%s0.png' % (sp, fr)); os.makedirs(os.path.dirname(p), exist_ok=True); open(p, 'wb').write(png); made += 1
    note('model-only frames given a transparent image: %d' % made)

    # 7. the tree's fingerprint (the suite records which tree it passed), the report, and the pk3 only on a pass
    h = hashlib.sha256()
    for r, d, fs in sorted(os.walk(TREE)):
        d.sort()
        for f in sorted(fs):
            p = os.path.join(r, f); h.update(os.path.relpath(p, TREE).encode()); h.update(open(p, 'rb').read())
    fp = h.hexdigest()
    open(os.path.join(OUT, 'tree.sha256'), 'w').write(fp + '\n')
    open(os.path.join(OUT, 'BUILD_REPORT.txt'), 'w').write('%s %s, tree %s\n\n' % (NAME, VERSION, fp[:16]) + '\n'.join(REPORT) + '\n')
    print('\n'.join(REPORT)); print('tree', fp[:16])
    if want_pk3:
        sp = os.path.join(OUT, 'suite.json')
        S = json.load(open(sp)) if os.path.exists(sp) else {}
        if not (S.get('passed') is True and S.get('tree') == fp):
            raise SystemExit('NO PK3: the full rig suite has not passed on this tree (out/suite.json: %s)' % ('tree ' + str(S.get('tree', ''))[:16] + ', passed ' + str(S.get('passed')) if S else 'none'))
        pk3 = os.path.join(OUT, '%s_%s.pk3' % (NAME, VERSION))
        pack(pk3)
        print(pk3, os.path.getsize(pk3) // 1024, 'KB')

def pack(pk3, tree=TREE):
    with zipfile.ZipFile(pk3, 'w', zipfile.ZIP_DEFLATED) as z:
        for dp, dn, fn in os.walk(tree):
            dn.sort()
            for f in sorted(fn):
                p = os.path.join(dp, f)
                z.write(p, os.path.relpath(p, tree).replace(os.sep, '/'), compress_type=zipfile.ZIP_LZMA if f.lower().endswith('.md3') else zipfile.ZIP_DEFLATED)

if __name__ == '__main__':
    main('--pk3' in sys.argv)
