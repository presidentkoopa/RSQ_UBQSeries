"""TEST ONLY: drive every magazine gun's VR reload in the rig and report the phases it reached.

Geometry comes from the probe's own dump of RSR_Guns (the pack's tables), so nothing is typed in.
The off hand is posed like the gun hand, but the left hand's L axis is mirrored (the Rifle run
put the magazine 2 x 3.9 cm off the axis), so the magazine's in-hand offset is flipped in L.
"""
import re, sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
import rig

CLS = {1: 'Rifle', 2: 'BrutalPistol', 3: 'BrutalSMG', 4: 'MP40', 5: 'AssaultShotgun', 6: 'RailGun',
       7: 'Plasma_Gun', 8: 'Sniper', 9: 'Rocket_Launcher', 10: 'MG42', 11: 'Flamethrower2',
       12: 'IncendiaryLauncher', 13: 'Unmaker', 14: 'Devastator', 15: 'NukeLauncher',
       16: 'HellishMissileLauncher', 17: 'Minigun', 18: 'Machinegun'}

def with_pouch(s):
    """reach to a pouch (off hand 40 cm left, 30 down) before taking a magazine: CanTakeMag refuses a
    hand within POUCH_MIN (20 cm) of the magazine, and some guns' wells are near the rest pose"""
    return s.replace('qz_ltrigger 1; wait 12;', 'qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 12;' % rig.lpose(0, 40, -30), 1)

def tables():
    t = open(rig.OUT + '/boot.log', errors='replace').read()
    g = {}
    for m in re.finditer(r'B22 GUN (\d+) well (\S+) (\S+) (\S+) axis (\S+) (\S+) (\S+) mouth (\S+) top (\S+) (\S+) (\S+) '
                         r'centre \S+ \S+ \S+ handle (\d) grab (\S+) (\S+) (\S+) pull (\S+) (\S+) (\S+) travel (\S+) rule (\d) reserve (\S+)', t):
        v = m.groups()
        f = lambda a, b: tuple(float(x) for x in v[a:b])
        g[int(v[0])] = dict(W=f(1, 4), A=f(4, 7), M=float(v[7]), T=f(8, 11), handle=int(v[11]), G=f(12, 15),
                            P=f(15, 18), travel=float(v[18]), rule=int(v[19]), reserve=v[20])
    return g

def at(g, d, mirror=True):
    # The left hand is the gun hand mirrored in L. For a well that takes its magazine from the side
    # (|axis L| large) the hand is also turned 180 degrees about U, which flips F and L back: the
    # magazine then points along the axis instead of opposite it.
    side = abs(g['A'][1]) > 0.5
    t = g['T']
    T = (-t[0], t[1], t[2]) if side else (t[0], -t[1] if mirror else t[1], t[2])
    p = [g['W'][k] + g['A'][k] * d - T[k] for k in range(3)]
    return rig.lpose(*p, yaw=180.0 if side else 0.0)

def script(i, g, mirror=True):
    c = CLS[i]
    s = ('wait 120; god; rsq_extra_weapons 1; rsr_reload 1; rsr_grab_with 0; rsr_debug 1; give %s; give %s 400; use %s; wait 80; '
         '+attack; wait 12; -attack; wait 25; +reload; wait 4; -reload; wait 30; qz_ltrigger 1; wait 12; '
         'qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 25; qz_ltrigger 0; wait 40; quit'
         % (c, g['reserve'], c, at(g, g['M'] + 3, mirror), at(g, g['M'] * 0.5, mirror), at(g, 0, mirror)))
    return s

def run(i, g, mirror=True, tag=''):
    rc, _ = rig.run('mag%d%s' % (i, tag), script(i, g, mirror), 220)
    t = open(rig.OUT + '/mag%d%s.log' % (i, tag), errors='replace').read()
    ph = re.findall(r'rsr t\d+ gun %d: (\w+) -> (\w+)' % i, t)
    trail = [ph[0][0]] + [b for a, b in ph] if ph else []
    side = re.findall(r'B22 T \d+ gun %d CARRY .* side (\S+) ang (\S+)' % i, t)
    errs = [l for l in t.splitlines() if re.search(r'VM abort|Script error|exception|Unknown', l) and 'voxeldef' not in l and 'Unknown type' not in l]
    refused = re.findall(r'rsr t\d+: reload refused.*', t)
    return dict(gun=i, cls=CLS[i], trail=trail, last_side=side[-1] if side else None, errs=errs[:3], refused=refused[:1])

if __name__ == '__main__':
    g = tables()
    which = [int(x) for x in sys.argv[1:]] or sorted(g)
    for i in which:
        r = run(i, g[i])
        print('%2d %-18s %-60s side/ang %s %s %s' % (r['gun'], r['cls'], '>'.join(r['trail']), r['last_side'],
              r['refused'] or '', r['errs'] or ''), flush=True)

PALM = (-1.5, 2.0, -4.5)

def handle_at(g, pull):
    """off-hand pose putting the (mirrored) palm on the charging handle, drawn back `pull` cm."""
    P = (PALM[0], -PALM[1], PALM[2])
    p = [g['G'][k] + g['P'][k] * pull - P[k] for k in range(3)]
    return rig.lpose(*p)

MAGAMMO = {1: 'RifleAmmo', 2: 'BDPistolAmmo', 3: 'BDSMGAmmo', 4: 'MP40Ammo', 5: 'AssaultShotgunAmmo', 8: 'xm21Ammo'}

def script_empty(i, g, magammo):
    c = CLS[i]
    tr = g['travel']
    return ('wait 120; god; rsq_extra_weapons 1; rsr_reload 1; rsr_grab_with 0; rsr_debug 1; give %s; give %s 400; use %s; wait 80; '
            'take %s 999; wait 10; +reload; wait 4; -reload; wait 30; qz_ltrigger 1; wait 12; '
            'qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 20; qz_ltrigger 0; wait 15; '
            'qz_lhand "%s"; wait 15; qz_ltrigger 1; wait 12; qz_lhand "%s"; wait 10; qz_lhand "%s"; wait 15; qz_ltrigger 0; wait 40; quit'
            % (c, g['reserve'], c, magammo, at(g, g['M'] + 3), at(g, g['M'] * 0.5), at(g, 0),
               handle_at(g, 0), handle_at(g, tr * 0.5), handle_at(g, tr * 1.05)))

def run_empty(i, g):
    rig.run('empty%d' % i, script_empty(i, g, MAGAMMO[i]), 240)
    t = open(rig.OUT + '/empty%d.log' % i, errors='replace').read()
    ph = re.findall(r'rsr t\d+ gun %d: (\w+) -> (\w+)' % i, t)
    return [ph[0][0]] + [b for a, b in ph] if ph else []
