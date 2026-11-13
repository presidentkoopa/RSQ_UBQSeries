"""Build RSQ_WeaponsOfSaturn: Weapons of Saturn rebuilt in ZScript for VR, on BD22 VR's meshes, hands and reload systems.

    python3 tools/build.py            -> out/tree/ (the pack, unzipped) and out/BUILD_REPORT.txt
    python3 tools/build.py --pk3      -> also out/RSQ_WeaponsOfSaturn_<ver>.pk3, ONLY if out/suite.json says the full rig
                                         suite passed on this exact tree (tools/suite.py writes it). No pass, no pk3.

What goes in (ARCH.md):
  src/                 the rebuild: zscript/wos/*.zs (the guns, the base, WoS's non-weapon actors), hand-written lumps
  WoS (WOS)            its assets only: SOUNDS, SPRITES, SNDINFO, GLDEFS (renamed to RSQWS_), DECALDEFS, LANGUAGE.
                       Never its ACTORS / DECORATE / ACS / LOADACS / CVARINFO / MENUDEF / MAPINFO.
  Voxels of Saturn     the pickups (VOX); its dead BELT entry dropped; the Beretta's pickup under RQWP (PIST is a HUD sprite)
  BD22 VR (lib.mdl, lib.zs_port)   the model blocks of each gun's BD22 mesh under this pack's class, and the VR systems
                       (hands, reload, pump, break-open, underbarrel, flick, dual, scope, ballistics, casings) with
                       RSQ_Alias naming which BD22 gun each RSQWS_ gun stands for.
  the 1911             RS ModelSwapper's BrutalWolf 1911 mesh, seated on the FBX pistol hand (tools/seat_1911.py) with its own
                       reload row 19 (tools/row_1911.py) and its own model blocks (RQ1M / RQ1P / RQ1W)."""
import glob, hashlib, json, os, re, shutil, struct, sys, zipfile, zlib
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(HERE, 'lib'))
import mdl, zs_port
BD = mdl.BD
# BD22 VR scripts this pack carries beyond the earlier port's set: the contact saw (owner: "Port BD22 VR's contact saw")
# and the rocket lock-on (SPEC: the Saturn V's alt fire)
zs_port.FILES = zs_port.FILES + ['rsq/pose.zs', 'rsvr/melee.zs', 'rsq/rlock.zs']
WOS = '/home/claude/src/saturn'
VOX = '/home/claude/src/wosvox'
MS1911 = '/home/claude/presidentkoopa/rs_modelswapper/cards/brutalwolf/1911'
CFX, RSBS = '/home/claude/rs_combatfx/sounds', '/home/claude/rs_ballistics/sounds/rsb'
GRENADE = '/home/claude/presidentkoopa/rsq_ubqseries/Grenade/models/rsqgn'
OUT = os.path.join(ROOT, 'out'); TREE = os.path.join(OUT, 'tree')
NAME, VERSION = 'RSQ_WeaponsOfSaturn', '0.1.0'

# ------------------------------------------------------------------------------------------------ the guns (SPEC.md)
# class -> the BD22 gun whose mesh / tables it uses (SPEC "Meshes"); the 1911 is BrutalPistol's tables with its own mesh + row 19
GUNS = {'RSQWS_Knuckles': 'Melee_Attacks', 'RSQWS_Motorsaw': 'Chain_saw', 'RSQWS_Beretta': 'BrutalPistol', 'RSQWS_1911': 'BrutalPistol',
        'RSQWS_MP40': 'MP40', 'RSQWS_Riotgun': 'Shot_Gun', 'RSQWS_Coachgun': 'SSG', 'RSQWS_MachineRifle': 'Rifle', 'RSQWS_Minigun': 'Minigun',
        'RSQWS_SaturnV': 'Rocket_Launcher', 'RSQWS_NovaRifle': 'RailGun', 'RSQWS_TITAN': 'NukeLauncher'}
OWN_MESH = {'RSQWS_1911'}          # its BD22 blocks on models/bd/BrutalPistol are replaced by the 1911's own
# the magazine hand reload (RSR_Guns): class -> row, magazine (Ammo2), reserve (Ammo1), racks
RSR = {'RSQWS_Beretta': (2, 'RSQWS_9mm', 'Clip', True), 'RSQWS_1911': (19, 'RSQWS_ACP', 'RSQWS_Bullets', True),
       'RSQWS_MP40': (4, 'RSQWS_MP40Ammo', 'Clip', True), 'RSQWS_MachineRifle': (1, 'RSQWS_Magazine', 'RSQWS_RifleAmmo', True),
       'RSQWS_Minigun': (17, 'RSQWS_NatoBelt', 'RSQWS_Nato', False), 'RSQWS_SaturnV': (9, 'RSQWS_RocketRounds', 'RocketAmmo', False),
       'RSQWS_NovaRifle': (6, 'RSQWS_Cellpak', 'Cell', False), 'RSQWS_TITAN': (15, 'RSQWS_BFGCell', 'Cell', False)}
# dual wield: class, its magazine, magazine max, backpack max, menu name, on by default
DUAL = [('RSQWS_Beretta', 'RSQWS_9mm', 11, 16, 'Handgun', True), ('RSQWS_1911', 'RSQWS_ACP', 8, 8, '1911', True),
        ('RSQWS_MP40', 'RSQWS_MP40Ammo', 32, 32, 'MP40', True), ('RSQWS_MachineRifle', 'RSQWS_Magazine', 31, 41, 'Maschine Rifle', True),
        ('RSQWS_NovaRifle', 'RSQWS_Cellpak', 60, 60, 'Nova Rifle', False), ('RSQWS_Riotgun', 'RSQWS_LoadedShell', 9, 9, 'Riot Gun', False),
        ('RSQWS_Coachgun', 'RSQWS_LoadedShells', 2, 2, 'Coach Gun', False)]
BDCOPY = {'BrutalPistol': 'RSQ_Off_BrutalPistol', 'MP40': 'RSQ_Off_MP40', 'Rifle': 'RSQ_Off_Rifle', 'RailGun': 'RSQ_Off_RailGun',
          'Shot_Gun': 'RSQ_Off_Shot_Gun', 'SSG': 'RSQ_Off_SSG'}
PICKUPS = {'RQWP', 'COLP', 'CSAW', 'MPIC', 'SHAT', 'DBBL', 'RIFL', 'MNIG', 'LAWN', 'PLAS', 'DEBF'}	# world sprites (voxels), not HUD frames
FISTS = 'RSQWS_Knuckles'
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

# ------------------------------------------------------------------------------------------------ the 1911's model blocks
def blocks_1911(row, off_cls=None):
    """the 1911's gun / part / hand / dropped blocks. Gun and parts at the seat (seat_1911.json via row_1911.json);
    the magazine in the hand and in the world at the card's own placements (they hang off the hand / the world, not the gun)."""
    p = row['place']
    seat = '\tScale -1.0000 1.0000 1.0000\n\tOffset %.3f %.3f 0.0\n\tZOffset %.3f\n\tAngleOffset %.3f\n\tPitchOffset %.3f\n\tRollOffset %.3f\t// tools/seat_1911.py: seated on the FBX pistol hand\n\tNoInterpolation\n' % tuple(p)
    def blk(cls, skins, place, frames, extra=''):
        s = ''.join('\tSurfaceSkin 0 %d "%s"\n' % (k, '1911.png' if on else 'rsr_clear.png') for k, on in enumerate(skins))
        return 'Model %s\n{\n\tPath "models/rsqws/1911"\n\tModel 0 "bw_1911.md3"\n%s%s%s%s}\n' % (cls, s, place, extra, frames)
    # the HUD frames the 1911's states show (pistols.zs), each on the card's own frames: idle 0, fire 1-4, the
    # magazine leaving 7-9 (measured: tools/row_1911.py), in again 9-7, the slide snap on 6
    HUD = [('PIST', 'E', 0), ('PIST', 'A', 1), ('PIST', 'B', 2), ('PIST', 'C', 3), ('PIST', 'D', 4)] + \
          [('PISR', f, n) for f, n in zip('ABCDEFGHIJ', (6, 6, 7, 7, 8, 8, 9, 9, 9, 9))] + \
          [('PISR', f, n) for f, n in zip('KLMNOP', (9, 9, 8, 8, 7, 7))] + [('PISR', 'Q', 6)] + [('PISR', f, 0) for f in 'RSTUVW']
    fi = lambda L: ''.join('\tFrameIndex %s %s 0 %d\n' % x for x in L)
    out = []
    for cls in [c for c in ('RSQWS_1911', off_cls) if c]:
        out.append(blk(cls, (1, 1, 1, 1, 1), seat, fi(HUD)))
        out.append(blk(cls, (1, 1, 1, 1, 0), seat, '\tFrameIndex RQ1M A 0 0\n'))       # without its magazine
        out.append(blk(cls, (1, 1, 1, 0, 1), seat, '\tFrameIndex RQ1M B 0 0\n'))       # without its slide (on its own layer while pulled)
        out.append(blk(cls, (1, 1, 1, 0, 0), seat, '\tFrameIndex RQ1M C 0 0\n'))       # without both
    out.append(blk('RSR_GunParts', (0, 0, 0, 0, 1), seat, '\tFrameIndex RQ1P A 0 0\n'))  # the magazine at the gun
    out.append(blk('RSR_GunParts', (0, 0, 0, 1, 0), seat, '\tFrameIndex RQ1P B 0 0\n'))  # the slide alone
    card = '\tScale -1.0000 1.0000 1.0000\n\tOffset 0.0000 0.0000 0.0\n\tZOffset -5.0000\n\tNoInterpolation\n'
    out.append(blk('RSQ_Hands', (0, 0, 0, 0, 1), card, '\tFrameIndex RQ1P A 0 0\n'))     # the magazine in the off hand
    world = '\tScale 0.3468 0.3468 0.3468\n\tOffset -9.1180 -0.0146 0.0\n\tZOffset 1.3471\n\tUSEACTORPITCH\n\tUSEACTORROLL\n'
    out.append(blk('RSR_DroppedMag', (0, 0, 0, 0, 1), world, '\tFrameIndex RQ1W A 0 0\n'))
    return "// GENERATED by tools/build.py: RS ModelSwapper's BrutalWolf 1911 (cards/brutalwolf/1911), surfaces 0 body, 1 trigger,\n" \
           "// 2 hammer, 3 slide, 4 magazine; a clear skin hides a surface (HUD models are alpha-tested).\n\n" + '\n'.join(out)

# ------------------------------------------------------------------------------------------------ the dual-wield copies
def dual_zs(present):
    L = ['// GENERATED by tools/build.py: the off-hand version of each dual gun (zscript/rsq/dual.zs). Its own magazine; it lives',
         '// in the off hand only, reloads by its stock reload (RSQWS_Gun.Reload: InOffHand) and fires on the off trigger.', '']
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
    wr('zscript/wos/dual.gen.zs', dual_zs(present))

    # 2. WoS's assets (never its code)
    for d in ('SOUNDS', 'SPRITES'):
        for p in glob.glob(os.path.join(WOS, d, '**/*'), recursive=True):
            rel = os.path.relpath(p, WOS)
            if os.path.isfile(p) and '/MONSTERS/' not in '/' + rel + '/': cp(p, rel)
    for f in ('SNDINFO', 'DECALDEFS', 'LANGUAGE', 'CREDITS.txt'):
        cp(os.path.join(WOS, f), f if f.endswith('.txt') else f + '.wos')
    gl = rd(os.path.join(WOS, 'GLDEFS'))
    names = set(c[6:] for c in C if c.startswith('RSQWS_'))
    gl, n = re.subn(r'(?im)^(\s*object\s+)(\w+)', lambda m: m.group(1) + ('RSQWS_' + m.group(2) if m.group(2) in names else m.group(2)), gl)
    gl, ng = re.subn(r'(?is)^\s*object\s+SaturnG\s*\{.*?^\}\s*', '\n', gl, flags=re.M)     # WoS's grenade: not carried (the alt is the lock-on)
    # the Titan's rounds in orange (owner): its three objects lit by orange copies of the stock BFGBALL lights (lights.pk3
    # filter/doom.id/gldefs.txt: same sizes and flicker, green -> orange)
    def orange(m):
        body = re.sub(r'\blight BFGBALL(_X\d)?\b', lambda k: 'light RSQWS_NOVA' + (k.group(1) or ''), m.group(2))
        return m.group(1) + body
    gl, no = re.subn(r'(?s)(object\s+RSQWS_(?:Nova|HyperNova|Residue)\s*\{)(.*?\n\})', orange, gl)
    if no != 3: raise SystemExit('Titan lights: %d of 3 objects' % no)
    gl += """
// tools/build.py: the Titan's rounds in the Nuker's orange (the stock BFGBALL lights, recoloured)
pointlight RSQWS_NOVA { color 1.0 0.6 0.25 size 120 attenuate 1 }
flickerlight RSQWS_NOVA_X1 { color 1.0 0.6 0.25 size 120 secondarySize 132 chance 0.3 attenuate 1 }
flickerlight RSQWS_NOVA_X2 { color 1.0 0.65 0.3 size 156 secondarySize 168 chance 0.3 attenuate 1 }
flickerlight RSQWS_NOVA_X3 { color 1.0 0.7 0.35 size 180 secondarySize 192 chance 0.3 attenuate 1 }
flickerlight RSQWS_NOVA_X4 { color 0.7 0.4 0.15 size 84 secondarySize 96 chance 0.3 attenuate 1 }
flickerlight RSQWS_NOVA_X5 { color 0.3 0.15 0.05 size 72 secondarySize 84 chance 0.3 attenuate 1 }
"""
    wr('TRNSLATE.rsqws', '// the Titan\'s rounds (zscript/wos/novacolor.zs): Doom\'s green ramp onto its orange ramp\nRSQWS_NovaOrange = "112:127=208:223"\n')
    wr('GLDEFS.wos', gl); note('GLDEFS: WoS object names on their RSQWS_ classes (%d objects)' % n)
    # the Beretta's pickup: WoS's PISTA0 is BD22's pistol HUD sprite name too, so the pickup is RQWP
    cp(os.path.join(WOS, 'SPRITES/BERETTA/PISTA0.png'), 'SPRITES/BERETTA/RQWPA0.png')
    os.remove(os.path.join(TREE, 'SPRITES/BERETTA/PISTA0.png'))
    # Voxels of Saturn: the pickups (BELT is a dead entry: nothing spawns it); the Beretta's on RQWP
    vd = rd(os.path.join(VOX, 'voxeldef.txt'))
    vd, nb = re.subn(r'(?is)^belta\s*=\s*"belta"\s*\{[^}]*\}\s*', '', vd)
    vd += '\n// tools/build.py: the Beretta\'s pickup sprite is RQWP (PIST is a HUD sprite name)\nrqwpa = "pista"\n{\n\tScale = 0.5\n}\n'
    wr('voxeldef.txt', vd)
    for p in glob.glob(os.path.join(VOX, 'voxels/*')):
        if not os.path.basename(p).upper().startswith('BELTA'): cp(p, 'voxels/' + os.path.basename(p))
    note('voxels: Voxels of Saturn, BELT dropped (%d), Beretta pickup on RQWP' % nb)
    # the pickups Voxels of Saturn has no definition for: BD22's voxel pack's (owner: "voxel pickups exist for everything in
    # the BD voxel file, so go get those"), the pack's own scale (its Voxeldef.txt), on this pack's pickup sprites
    BDVOX = '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/pk3/02_BD22_VoxelPack.pk3'
    bdv = [('mpica', 'MP40I0', 0.8, 'MP40'), ('plasa', 'SRCGA', 0.8, 'Nova Rifle (BD22 railgun)'), ('csawz', 'CSAWA', 0.9, 'Motorsaw (BD22 chainsaw)')]
    with zipfile.ZipFile(BDVOX) as z:
        for spr, kvx, sc, what in bdv:
            data = z.read('Voxels/Weapons/%s.kvx' % kvx)
            p = os.path.join(TREE, 'voxels', kvx + '.kvx'); open(p, 'wb').write(data)
            vd += '\n// %s: BD22 voxel pack Voxels/Weapons/%s.kvx\n%s = "%s"\n{\n\tScale = %.1f\n}\n' % (what, kvx, spr, kvx, sc)
    wr('voxeldef.txt', vd)
    note('voxels from the BD22 voxel pack: ' + ', '.join('%s %s' % (w, k) for s, k, c, w in bdv))


    # 3. BD22 VR's model blocks under this pack's classes (the 1911: its BD22 pistol-mesh blocks replaced by its own)
    alias = {g: GUNS[g] for g in present}
    malias = dict(alias)
    for d in D: malias['RSQ_Off_' + d[0]] = BDCOPY[GUNS[d[0]]]
    lumps, files, keyed, sprites, miss = mdl.build(malias, HELPERS)
    if miss: raise SystemExit('model files missing: %s' % miss[:5])
    row19 = json.load(open(os.path.join(HERE, 'row_1911.json')))
    if 'RSQWS_1911' in present:
        own = {'RSQWS_1911'} | ({'RSQ_Off_RSQWS_1911'} if any(d[0] == 'RSQWS_1911' for d in D) else set())
        dropped = 0
        for k in list(lumps):
            def keep(m):
                nonlocal dropped
                if m.group(1) in own and 'models/bd/BrutalPistol' in m.group(2):
                    dropped += 1; return ''
                return m.group(0)
            lumps[k] = re.sub(r'Model (\w+)\n\{(.*?)\n?\}\n', keep, lumps[k], flags=re.S)
        for c in own: keyed[c] = {x for x in keyed.get(c, set()) if x[0] not in ('PIST', 'PISR', 'RQPM')}
        lumps['MODELDEF.rsqws1911'] = blocks_1911(row19, 'RSQ_Off_RSQWS_1911' if 'RSQ_Off_RSQWS_1911' in own else None)
        for c in own:
            keyed[c] |= {('PIST', f) for f in 'ABCDE'} | {('PISR', f) for f in 'ABCDEFGHIJKLMNOPQRSTUVW'} | {('RQ1M', f) for f in 'ABC'}
        sprites |= {'RQ1M', 'RQ1P', 'RQ1W'}
        for f in ('bw_1911.md3', '1911.png', 'rsr_clear.png'): cp(os.path.join(MS1911, f), 'models/rsqws/1911/' + f)
        # the 1911's pickup (owner: "recolor the pistol one"): BD22's voxel pistol (pistG0) with its palette recoloured to the
        # 1911's own skin (tools/pickup_1911.py -> assets/pickup_1911), drawn as BD22 VR draws a voxel (MODELDEF.rsqvox's
        # pistG block: the kvx as a model, scale 0.8, AngleOffset 90), on the 1911's pickup sprite COLP A
        for f in ('pistG0.kvx', '1911pick.png'): cp(os.path.join(ROOT, 'assets/pickup_1911', f), 'models/rsqws/1911pickup/' + f)
        lumps['MODELDEF.rsqws1911'] += '\n// the 1911 lying on the floor: BD22\'s voxel pistol in the 1911\'s colours\nModel RSQWS_1911\n{\n\tModel 0 "models/rsqws/1911pickup/pistG0.kvx"\n\tSkin 0 "models/rsqws/1911pickup/1911pick.png"\n\tScale 0.8 0.8 0.8\n\tAngleOffset 90\n\tFrameIndex COLP A 0 0\n}\n'
        note('1911: %d BD22 pistol-mesh blocks replaced by its own (MODELDEF.rsqws1911, seat %s)' % (dropped, row19['place']))
    # the Rotary Cannon's magazine (owner: "when we 'grab a magazine' I want to see a half sized voxel ammo box in my hand";
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
        box[key] = ('\tPath "models/rsqws/ammobox"\n\tModel 0 "ammobox.md3"\n\tSkin 0 "%s"\n\tScale %.4f %.4f %.4f\n\tOffset %.3f %.3f 0.0\n\tZOffset %.3f\n'
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
    for f in ('ammobox.md3', 'ammoa.png', 'ammoa_empty.png'): cp(os.path.join(ROOT, 'assets/ammobox', f), 'models/rsqws/ammobox/' + f)
    note('Rotary Cannon magazine: BD22 voxel ammo box as an MD3 (18 units), in BD22 VR\'s three magazine blocks; dropped = empty skin')
    # Real Casing Models: BD22 VR's measured casings on WoS's casing sprites (CAS1 9 mm / .45, CAS2 12 ga, CAS3 rifle)
    CASE = {'RSQ_Case9mm': 'CAS1', 'RSQ_Case556': 'CAS3', 'RSQ_Case762': 'CAS3', 'RSQ_Hull12ga': 'CAS2'}
    def recase(m):
        body = re.sub(r'^[ \t]*FrameIndex[^\n]*\n?', '', m.group(3), flags=re.M).rstrip()
        return 'Model %s%s\n{%s\n%s\n}' % (m.group(1), m.group(2), body, '\n'.join('\tFrameIndex %s %s 0 0' % (CASE[m.group(1)], f) for f in 'ABCDEFGHIJKLMN'))
    lumps['MODELDEF.rsqcase'], nb = re.subn(r'Model (\w+)([^\n{]*)\n\{(.*?)\n\}', recase, rd(os.path.join(BD, 'MODELDEF.rsqcase')), flags=re.S)
    lumps['MODELDEF.rsqcase'] += ('\n// this pack: the 1911\'s .45 (RS Ballistics models/casings/casing_45.md3, its own scale), on WoS\'s casing sprite CAS1\n'
        'Model RSQ_Case45\n{\n\tPath "models/rsq/casings"\n\tModel 0 "casing_45.md3"\n\tSurfaceSkin 0 0 "casing_brass.png"\n\tSurfaceSkin 0 1 "casing_inner.png"\n'
        '\tSurfaceSkin 0 2 "casing_primer.png"\n\tScale 0.03279 0.03279 0.03279\n\tUSEACTORPITCH\n\tUSEACTORROLL\n' + ''.join('\tFrameIndex CAS1 %s 0 0\n' % f for f in 'ABCDEFGHIJKLMN') + '}\n')
    note('casing model blocks: %d' % nb)
    cptree(os.path.join(BD, 'models/rsq/casings'), 'models/rsq/casings')
    cp('/home/claude/rs_ballistics/models/casings/casing_45.md3', 'models/rsq/casings/casing_45.md3')
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
    if 'RSQWS_1911' in rows:     # row 19: a copy of row 2 (every function has one), then the 1911's own values
        g = re.sub(r'^(\t\tcase )2(:[^\n]*)$', r'\g<1>2\2\n\g<1>19\2', g, flags=re.M)
        g = g.replace('clearscope static int Count() { return 18; }', 'clearscope static int Count() { return 19; }')
        vec = lambda v: '(%.3f, %.3f, %.3f)' % tuple(v)
        for fn in ('Well', 'Axis', 'MagCentre', 'TopInHand', 'HandHook', 'WellHook', 'Grab', 'Pull', 'HandleHook', 'Scale', 'Offset'):
            g = set_case(g, fn, 19, vec(row19[fn]) + '\t// tools/row_1911.py: the BrutalWolf 1911 seated on the FBX pistol hand')
        for fn in ('Mouth', 'MagLen', 'Travel', 'BackAt'):
            g = set_case(g, fn, 19, '%.2f' % row19[fn])
        for fn in ('Channel', 'ChargeRule'): g = set_case(g, fn, 19, str(row19[fn]))
        g = set_case(g, 'BoltRatio', 19, '%.3f' % row19['BoltRatio'])
        for fn in ('HasHandle', 'HandleLayers'): g = set_case(g, fn, 19, 'true' if row19[fn] else 'false')
        for fn in ('SprGun', 'SprPart', 'SprWorld'): g = set_case(g, fn, 19, "'%s'" % row19[fn])
        snd19 = dict(row19, SndOut='rsqws/1911/reload1', SndIn='rsqws/1911/reload2', SndFwd='rsqws/1911/reload3')	# owner's 1911.zip, in its order
        for fn in ('ReadySprites', 'SndOut', 'SndIn', 'SndBack', 'SndFwd', 'SndLand'): g = set_case(g, fn, 19, '"%s"' % snd19[fn])
        note('reload row 19 RSQWS_1911: its own geometry, sprites RQ1M / RQ1P / RQ1W, the card\'s (= BD22 pistol) sounds')
    # Weapon Effects = OG (owner: "all sounds come from OG WoS mod unless ballistics set to" Enhanced): the hand reload plays
    # each gun's own WoS reload sounds (WoS ACTORS' reload states, in their order); Enhanced keeps BD22 VR's row sounds
    # (RS Combat FX / RS Ballistics through BD's names, SNDINFO.rsqfx). "" = no sound for that step in WoS.
    OGSND = {  # row: (magazine out, magazine in, slide / bolt back, forward, magazine lands)
        2: ('weapons/beretta/magdrop', 'weapons/beretta/snap', 'weapons/beretta/snap', 'weapons/beretta/snap', ''),
        19: ('weapons/1911/reload', 'weapons/1911/snap', 'weapons/1911/slide', 'weapons/1911/slide', ''),
        4: ('weapons/beretta/magdrop', 'weapons/MP40/reload', 'weapons/MP40/cock', 'weapons/MP40/cock', ''),
        1: ('weapons/rifle/out', 'weapons/rifle/in', 'weapons/rifle/bolt', 'weapons/rifle/slap', ''),
        17: ('weapons/chaingun/feed', 'weapons/chaingun/feed', '', '', ''),
        9: ('weapons/launcher/up', 'weapons/launcher/load', '', '', ''),
        6: ('weapons/plasmagun/reload', 'weapons/plasmagun/reload', '', '', ''),
        15: ('weapons/bfg/reload', 'weapons/bfg/reload', '', '', '')}
    og = ['// GENERATED by tools/build.py: the hand reload\'s sounds with Weapon Effects = OG (WoS\'s own)', 'class RSQWS_OGSnd abstract', '{',
          '\t// k: 0 out, 1 in, 2 back, 3 forward, 4 lands. "-": no WoS sound known for that row (the row\'s own plays)',
          '\tclearscope static String Get(int i, int k)', '\t{']
    for r, v in OGSND.items():
        og.append('\t\tif (i == %d)\t{ static const String s%d[] = { %s }; return s%d[k]; }' % (r, r, ', '.join('"%s"' % x for x in v), r))
    og += ['\t\treturn "-";', '\t}', '}', '']
    wr('zscript/wos/ogsnd.gen.zs', '\n'.join(og))
    for k, fn in enumerate(('SndOut', 'SndIn', 'SndBack', 'SndFwd', 'SndLand')):
        g, n = re.subn(r'(clearscope static String %s\(int i\)\n\t\{\n)' % fn,
                       lambda m: m.group(1) + '\t\tif (!RSQWS_FX.Enhanced())\t// this pack: Weapon Effects = OG -> WoS\'s own reload sounds\n\t\t{\n\t\t\tString og = RSQWS_OGSnd.Get(i, %d);\n\t\t\tif (og != "-")\n\t\t\t\treturn og;\n\t\t}\n' % k, g, count=1)
        assert n == 1, fn
    for c, (row, mag, res, racks) in rows.items():
        g = set_case(g, 'Reserve', row, '"%s"' % res); g = set_case(g, 'MagAmmo', row, '"%s"' % mag)
        g = set_case(g, 'NoMag', row, '""'); g = set_case(g, 'ReloadToken', row, '""')
        g = set_case(g, 'ChargeToken', row, '"RSR_Charge"' if racks else '""')
        note('reload row %d %s: magazine %s, reserve %s%s' % (row, c, mag, res, ', racks' if racks else ''))
    if 'RSQWS_Riotgun' in present:      # the pump table's row 1 (the Shot_Gun mesh): the Riot Gun's tube and sounds
        bp = os.path.join(BD, 'zscript/rsr/rsr_pump_guns.zs')
        PUMP = (('WaitLabels', '"RSP_LoadWait RSP_LoadWaitE RSP_P1Wait RSP_P2Wait"'), ('Loaded', '"RSQWS_LoadedShell"'), ('MagAmmo', '"RSQWS_LoadedShell"'),
                ('Reserve', '"Shell"'), ('Cap', '9'), ('SndBack', '"weapons/riotgun/pumpback"'), ('SndFwd', '"weapons/riotgun/pumpforth"'), ('SndShell', '"weapons/riotgun/load"'))
        note('pump row 1 RSQWS_Riotgun: tube RSQWS_LoadedShell (9), reserve Shell, WoS pump sounds')
    if 'RSQWS_Coachgun' in present:     # the break-open table's row 1 (the SSG mesh)
        BRK = (('Loaded', '"RSQWS_LoadedShells"'), ('Reserve', '"Shell"'), ('Unloaded', '""'), ('ReloadToken', '""'), ('SndOpen', '"weapons/shellslinger/open"'))
        note('break-open row 1 RSQWS_Coachgun: loaded RSQWS_LoadedShells, reserve Shell')
    patches = {
        'rsr/rsr_m203.zs': [("Name n = cv && cv.GetInt() == 1 ? 'GrenadeAmmo' : 'AmmoRocket';\n\t\tclass<Inventory> c = n;",
            "Name n = cv && cv.GetInt() == 1 ? 'RSQGN_Ammo' : 'RocketAmmo';\t// this pack: RSQ Grenade's grenades, or rockets\n\t\tclass<Inventory> c = n;\n\t\tif (!c)\n\t\t\tc = 'RocketAmmo';\t// RSQ Grenade is not loaded: rockets", 1)],
        'rsq/dual.zs': [("Name n = RSQ_Alias.Exact(w);", "Name n = w.GetClassName();", 2), ("off ? 'RSQ_Hands' : 'Melee_Attacks'", "off ? 'RSQ_Hands' : '%s'" % FISTS, 1),
            (re.compile(r"^(\t+)Silvergun\(mo, n\);", re.M), r"\1// (this pack has no Silvergun: BD22 VR's Silvergun(mo, n) is not called)", 1)],
        'rsq/dualhands.zs': [("Name cn = w ? w.GetClassName() : 'None';", "Name cn = w ? RSQ_Alias.BD(w) : 'None';", 1)],
        # the live scope (owner: "port live scope, always on"): 3x real, never the dot, no alt-fire toggle
        'rsq/scope.zs': [("static const bool v[] = { false, true, true };", "static const bool v[] = { false, false, false };\t// this pack: always on, alt fire is the gun's own", 1)],
        'rsq/scope_real.zs': [("double mag = (cv && cv.GetInt() == 1) ? RSQ_ScopeTable.Mag(i) : 1.0;", "double mag = RSQ_ScopeTable.Mag(i);\t// this pack: always the real 3x", 1)],
        'rsq/hands.zs': [("if (sci > 0 && RSQ.PlayerInt(mo, RSQ_ScopeTable.ModeCVar(sci), 0) != 0)", "if (sci > 0)\t// this pack: the real scope always, never the dot", 1)],
        # Ballistics (owner: one option, not a second "Weapon Effects"): BD22 VR's own gates, unchanged. Stock = WoS's own
        # look and sounds; Low / Max = RS Ballistics (flash, tail, crack, impacts) on True Bullets or hitscan alike.
        'rsq/ballistics.zs': [("e.Thing.player.ReadyWeapon.GetClassName()", "RSQ_Alias.BD(e.Thing.player.ReadyWeapon)", 1),
            ("tracer.player.ReadyWeapon.GetClassName()", "RSQ_Alias.BD(tracer.player.ReadyWeapon)", 1)],
        'rsq/flash.zs': [("String n = w.GetClassName();", "String n = RSQ_Alias.BD(w);", 1)],
        # rsq/flick.zs: BD22 VR's, unchanged but for the alias (owner: "just diff your flick reload against bd as bd works"):
        # it reloads a gun in each hand, a lone SSG (the Coach Gun) and a lone rifle's underbarrel. No 'Reloading = Flick' mode.
        'rsq/casings.zs': [(re.compile(r"Name n = c\.GetClassName\(\);"), "Name n = c.GetClassName();\n\t\t// this pack: WoS's casings under the names BD22 VR's tables know\n\t\tif (n == 'RSQWS_9mmCasing' || n == 'RSQWS_45Casing') n = 'PistolCasing';\n\t\telse if (n == 'RSQWS_RifleCasing' || n == 'RSQWS_ChaingunCasing') n = 'EmptyBrass';\n\t\telse if (n == 'RSQWS_ShotgunCasing') n = 'ShotgunCasing';", 1),
            ("mo.player.ReadyWeapon ? mo.player.ReadyWeapon.GetClassName() : 'None'", "RSQ_Alias.BD(mo.player.ReadyWeapon)", 2),
            ("return t ? PlayerPawn(t.target) : null;", "if (t && PlayerPawn(t.target))\n\t\t\treturn PlayerPawn(t.target);\n\t\treturn multiplayer ? null : players[consoleplayer].mo;\t// this pack: WoS's casings do not always carry their shooter", 1)],
        'rsr/vreload.zs': [("PlayerInt(mo.player, 'rsr_rig_pouch', 1) == 0", "PlayerInt(mo.player, 'rsr_pouch', 0) != 2\t/* this pack: New magazine from = Tactical Rig's pouch */", 1),
            ('return i >= 1 && i < h.Size() ? h[i] : "RsrHold";', 'if (i == 19) i = 2;\t// this pack: row 19 is held as the pistol is\n\t\treturn i >= 1 && i < h.Size() ? h[i] : "RsrHold";', 1)],
    }
    if 'RSQWS_1911' in present:
        m19, c19 = row19['Muzzle'], row19['CasingPort']
        patches['rsq/muzzle.zs'] = [("\t\tif (RSQ_Alias.BD(w) == 'BrutalPistol')\treturn",
            "\t\tif (w is 'RSQWS_1911')\treturn (%.2f, %.2f, %.2f);\t// this pack: the 1911's own muzzle at its seat (tools/row_1911.py)\n\t\tif (RSQ_Alias.BD(w) == 'BrutalPistol')\treturn" % tuple(m19), 1)]
        patches['rsq/casings.zs'].append(("\t\tif (RSQ_Alias.BD(w) == 'BrutalPistol')\t\treturn",
            "\t\tif (w is 'RSQWS_1911')\t\treturn (%.1f, %.1f, %.1f);\t// this pack: the 1911's ejection port at its seat (tools/row_1911.py)\n\t\tif (RSQ_Alias.BD(w) == 'BrutalPistol')\t\treturn" % tuple(c19), 1))
    # the contact saw only (owner: "Port BD22 VR's contact saw"): BD22 VR's melee reads no other weapon here (no axe, sword,
    # pistol whip or butt strike: not in the SPEC), and each cut is the Motorsaw's own (RSQWS_SawCut, WoS's saw damage)
    patches['rsvr/melee.zs'] = [
        (re.compile(r"(static int KindOf\(PlayerPawn mo\)\n\t\{\n\t\tlet p = mo\.player;\n\t\tif \(!p \|\| !p\.ReadyWeapon \|\| p\.PendingWeapon != WP_NOCHANGE \|\| mo\.health <= 0\)\n\t\t\treturn 0;\n).*?(\n\t\}\n)", re.S),
         r"\1\t\t// this pack: the Motorsaw is the only weapon BD22 VR's melee reads (the contact saw)\n\t\treturn p.ReadyWeapon is 'RSQWS_Motorsaw' ? SAW : 0;\2", 1),
        (re.compile(r"(static int KindOfOff\(PlayerPawn mo\)\n\t\{\n)"), r"\1\t\treturn 0;\t// this pack: no off-hand melee weapon (axe, pistol whip)\n", 1),
        ("Launch(mo, 'SawDamageHorizontal',", "Launch(mo, 'RSQWS_SawCut',", 1),
        ("RSQ_Alias.Exact(a) == 'BrutalAxe'", "a.GetClassName() == 'BrutalAxe'", 1)]
    patches['rsq/rlock.zs'] = [
        ("let c = CVar.GetCVar('rsa_rl_lock', p);\n\t\t\tbool on = c && c.GetBool() &&", "bool on = true &&\t// this pack: the Saturn V's alt fire is always the lock-on (SPEC)\n\t\t\t\t", 1),
        ("\n\t\t\t\t&& !RSA_Handler.AltDown(mo);", ";\t// (no LegenDoom mode here)", 1),
        ("!(r is 'Rocket2')", "!(r is 'RSQWS_SaturnRocket')", 1)]
    # the 1911's brass: RS Ballistics' .45 (owner), lent when the 1911 throws it
    patches['rsq/casings.zs'].append(("bool lent = RSQ_CaseModels.Lend(c, RSQ_Alias.BD(mo.player.ReadyWeapon), n);",
        "bool lent = RSQ_CaseModels.Lend(c, mo.player.ReadyWeapon is 'RSQWS_1911' ? Name('RSQWS_1911') : RSQ_Alias.BD(mo.player.ReadyWeapon), n);\t// this pack: the 1911's own .45", 1))
    patches['rsq/casemodels.zs'] = [("\tstatic Name Holder(Name gun, Name casing)\n\t{\n",
        "\tstatic Name Holder(Name gun, Name casing)\n\t{\n\t\tif (gun == 'RSQWS_1911')\t// this pack: RS Ballistics' .45 (src/zscript/wos/case45.zs)\n\t\t\treturn 'RSQ_Case45';\n", 1)]
    zs_port.port(TREE, patches)
    for rel, rows_ in (('zscript/rsr/rsr_pump_guns.zs', PUMP if 'RSQWS_Riotgun' in present else ()), ('zscript/rsr/rsb_guns.zs', BRK if 'RSQWS_Coachgun' in present else ())):
        if not rows_: continue
        bt = rd(os.path.join(TREE, rel))
        for fn, val in rows_: bt = set_case(bt, fn, 1, val)
        wr(rel, bt)
    wr('zscript/rsr/rsr_guns.bd.zs', g)
    al = ['// GENERATED by tools/build.py: which BD22 gun each RSQWS_ gun stands for. BD22 VR\'s tables (hands, muzzle, recoil',
          '// follow, reload geometry) are keyed by BD22\'s class names; this is the one place the two meet.',
          'class RSQ_Alias abstract', '{', '\tclearscope static Name BD(Weapon w)', '\t{', '\t\tif (!w)', "\t\t\treturn 'None';", '\t\tName n = w.GetClassName();']
    for k, v in alias.items(): al.append("\t\tif (n == '%s' || n == 'RSQ_Off_%s')\treturn '%s';" % (k, k, v))
    al += ["\t\treturn 'None';", '\t}', '', '\t// by exact class: an off-hand version is BD22 VR\'s off-hand version, not the gun',
           '\tclearscope static Name Exact(Weapon w)', '\t{', '\t\tif (!w)', "\t\t\treturn 'None';", '\t\tName n = w.GetClassName();'] + \
          ["\t\tif (n == 'RSQ_Off_%s')\treturn '%s';" % (d[0], BDCOPY[GUNS[d[0]]]) for d in D] + ['\t\treturn BD(w);', '\t}', '}', '',
           '// the underbarrel\'s ammo at the start (owner: "ensure player starts with 3 missiles if RSQ Grenade not loaded"): without',
           '// RSQ Grenade the underbarrel fires rockets (rsr_m203.zs AmmoClass, this pack), so each life starts with three',
           'class RSQ_Started : Inventory { Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE } }',
           'class RSQ_Start : EventHandler', '{', '\toverride void PlayerEntered(PlayerEvent e)', '\t{',
           '\t\tlet mo = players[e.PlayerNumber].mo;', "\t\tif (!mo || mo.CountInv('RSQ_Started') > 0)", '\t\t\treturn;',
           "\t\tmo.GiveInventory('RSQ_Started', 1);", "\t\tName gn = 'RSQGN_Ammo';", '\t\tclass<Inventory> g = gn;', '\t\tif (!g)',
           "\t\t\tmo.GiveInventory('RocketAmmo', 3);", '\t}', '}', '',
           '// every sprite name the model definitions key, named once so MODELDEF knows them',
           'class RSQ_BDSprites : Actor', '{', '\tStates', '\t{', '\tSpawn:', '\t\tTNT1 A 0;'] + \
          ['\t\t"%s" A 0;' % s for s in sorted(sprites)] + ['\t\tStop;', '\t}', '}', '']
    wr('zscript/rsq/alias.zs', '\n'.join(al))
    cp(os.path.join(HERE, 'lib/stubs.zs'), 'zscript/rsq/stubs.zs')
    cp(os.path.join(HERE, 'lib/stubs_melee.zs'), 'zscript/rsq/stubs_melee.zs')
    wr('zscript/rsq/dualtable.zs', dualtable(D))
    own = sorted(os.path.relpath(p, os.path.join(ROOT, 'src')) for p in glob.glob(os.path.join(ROOT, 'src/zscript/**/*.zs'), recursive=True))
    inc = own + ['zscript/wos/dual.gen.zs', 'zscript/wos/ogsnd.gen.zs', 'zscript/rsq/alias.zs', 'zscript/rsq/stubs.zs', 'zscript/rsq/stubs_melee.zs', 'zscript/rsq/dualtable.zs'] + ['zscript/' + f for f in zs_port.FILES]
    wr('ZSCRIPT.zs', 'version "4.14"\n// %s %s: Weapons of Saturn rebuilt in ZScript for VR, on BD22 VR\'s meshes, hands and reload (RS_Brutal22WeaponsQ)\n' % (NAME, VERSION)
       + ''.join('#include "%s"\n' % i for i in inc))

    # 5. lumps
    H = ['RSVR_HandSync', 'RSQ_PoseHandler', 'RSVR_MeleeHandler', 'RSQ_Handler', 'RSR_ReloadHandler', 'RSB_Handler', 'RSP_Handler', 'RSK_M203Handler', 'RSQ_Muzzle', 'RSQ_HandTone',
         'RSQ_Start', 'RSA_Casings', 'RSQ_AmmoHud', 'RSQ_Flick', 'RSQ_Ballistics', 'RSQ_FlashHandler', 'RSQ_PlayerRounds', 'RSQ_ShotFX',
         'RSQ_Dual', 'RSQ_DualHands', 'RSQ_DualKey', 'RSQ_ScopeReal', 'RSQWS_KickKey', 'RSQ_RocketLock', 'RSQWS_NovaColor']
    wr('MAPINFO.rsq', 'gameinfo\n{\n\tPlayerClasses = "RSQWS_PistolShotgunPlayer", "RSQWS_Pistol1911Player", "RSQWS_ShotgunMP40Player"\n\tAddEventHandlers = %s\n}\n' % ', '.join('"%s"' % h for h in H))
    dc = ['user bool rsq_dual_start = true;\t// Start With Two Pistols'] + ['user bool rsq_dual_%d = %s;\t// dual %s' % (k, 'true' if d[5] else 'false', d[4]) for k, d in enumerate(D)]
    wr('CVARINFO.rsq', rd(os.path.join(HERE, 'lib/CVARINFO.base')) + '\n'.join(dc) + '\n')
    dm = ['', 'OptionMenu "RSQ_DualOptions"', '{', '\tTitle "DUAL OPTIONS"', '\tOption "Start With Two Pistols", "rsq_dual_start", "OnOff"'] + \
         ['\tOption "%s", "rsq_dual_%d", "OnOff"' % (d[4], k) for k, d in enumerate(D)] + ['}', '']
    wr('MENUDEF.rsq', rd(os.path.join(HERE, 'lib/MENUDEF.base')) + '\n'.join(dm))
    wr('KEYCONF.rsq', 'addkeysection "Weapons of Saturn VR" rsqwsvr\naddmenukey "Quick Kick" rsqws_kickkey\nalias rsqws_kickkey "netevent rsqws_kick"\n'
       'addmenukey "Dual Wield" rsq_dualkey\nalias rsq_dualkey "netevent rsq_dual"\n')
    wr('SNDINFO.rsr', rd(os.path.join(BD, 'SNDINFO.rsr')) + "\n// the underbarrel launcher's sounds (BD22's names, Doom 2's own lumps)\nGrenadeLauncher/Open\tdsdbopn\nGrenadeLauncher/Close\tdsdbcls\nGrenadeLauncher/Load\tdsdbload\nWeapon/Empty\tdsswtchn\n"
       "\n// tools/build.py: a trigger on an empty gun (RSQWS_Gun.RSQWS_Empty): Doom 2's own click\nRSQWS/dry\tdsswtchn\n"
       "\n// the 1911's own sounds at Ballistics Low / Max (owner 2026-11-13: 1911.zip; never at Stock, which is WoS's)\n"
       "rsqws/1911/fire\t\"sounds/rsqws1911/fire.ogg\"\nrsqws/1911/reload1\t\"sounds/rsqws1911/reload1.ogg\"\n"
       "rsqws/1911/reload2\t\"sounds/rsqws1911/reload2.ogg\"\nrsqws/1911/reload3\t\"sounds/rsqws1911/reload3.ogg\"\n")
    for f in ('fire.ogg', 'reload1.ogg', 'reload2.ogg', 'reload3.ogg'): cp(os.path.join(ROOT, 'assets/sounds1911', f), 'sounds/rsqws1911/' + f)
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
    for f in ('nade.md3', 'nade_impact.png', 'rsqgn_clear.png'): cp(os.path.join(GRENADE, f), 'models/rsqm203/' + f)
    wr('MODELDEF.rsqm203', rd(os.path.join(HERE, 'lib/MODELDEF.rsqm203')))

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
