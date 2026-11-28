"""TEST ONLY (2026-11-09): the VR HAND RELOAD of a ModelSwapper set's magazine guns on the rig, and whether the
mesh survives it. mags.py's method (the kit's), re-pointed at a mod + MS set instead of BD22:

    python3 -B tools/rig/msmags.py <tag> <mod.pk3> <set.pk3> "Class:ReserveAmmo:slot,..."

One boot run dumps the set's RSR tables through the probe (B22 GUN lines), then one engine run per gun:
give, select, fire, press reload (RSR takes the key: the magazine drops), off-hand trigger grabs the magazine
(rsr_grab_with 0), the off hand is posed along the well axis into the well in three steps, released. The log
gives the RSR phase trail (rsr_debug), the magazine count before/after, and the weapon layer's sprite every tic
of the reload (B22 W lines): the MS anchor sprite constant = the mesh stayed; the mod's sprite = it dropped.
Data in /home/claude/rig/packs. One engine at a time (flock). bin/config/qzdoom.ini restored from git around runs.
"""
import os, re, sys, subprocess, zipfile
H = os.path.dirname(os.path.abspath(__file__)); RIG = H + '/bin'; DATA = '/home/claude/rig/packs'
sys.path.insert(0, H); import rig
OUT = H + '/runs'; os.makedirs(OUT, exist_ok=True)
PROBE = OUT + '/probe.pk3'
with zipfile.ZipFile(PROBE, 'w', zipfile.ZIP_DEFLATED) as z:
    for f in ('zscript.txt', 'MAPINFO.txt'): z.write(os.path.join(H, 'probe_ms', f), f)
INI = RIG + '/config/qzdoom.ini'
def reset_ini(): subprocess.call(['git', '-C', os.path.dirname(os.path.dirname(H)), 'checkout', '--', os.path.relpath(INI, os.path.dirname(os.path.dirname(H)))], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def run(name, files, script, secs=240):
    reset_ini()
    log = '%s/%s.log' % (OUT, name)
    for f in (log, log + '.out'):
        if os.path.exists(f): os.remove(f)
    cmd = ['flock', '-o', '-x', '/home/claude/rig.lock', 'timeout', str(secs), RIG + '/qz', '-iwad', DATA + '/doom2.wad', '-file'] + files + \
          ['-nosound', '-nomusic', '-warp', '1', '-skill', '3', '+logfile', log, '+' + script]
    with open(log + '.out', 'w') as fo:
        subprocess.run(cmd, stdout=fo, stderr=subprocess.STDOUT, cwd=RIG,
                       env=dict(os.environ, QZ_RES=os.environ.get('QZ_RES', '200'), EGL_PLATFORM='surfaceless', LIBGL_ALWAYS_SOFTWARE='1'))
    reset_ini()
    t = ''
    for f in (log, log + '.out'):
        if os.path.exists(f): t += open(f, errors='replace').read()
    return t

def tables(t):
    g = {}
    for m in re.finditer(r'B22 GUN (\d+) well (\S+) (\S+) (\S+) axis (\S+) (\S+) (\S+) mouth (\S+) top (\S+) (\S+) (\S+) '
                         r'centre \S+ \S+ \S+ handle (\d) grab (\S+) (\S+) (\S+) pull (\S+) (\S+) (\S+) travel (\S+) rule (\d) reserve (\S*)', t):
        v = m.groups(); f = lambda a, b: tuple(float(x) for x in v[a:b])
        g[int(v[0])] = dict(W=f(1, 4), A=f(4, 7), M=float(v[7]), T=f(8, 11), handle=int(v[11]), G=f(12, 15), P=f(15, 18), travel=float(v[18]), rule=int(v[19]), reserve=v[20])
    return g

def at(g, d):
    side = abs(g['A'][1]) > 0.5
    t = g['T']
    T = (-t[0], t[1], t[2]) if side else (t[0], -t[1], t[2])
    p = [g['W'][k] + g['A'][k] * d - T[k] for k in range(3)]
    return rig.lpose(*p, yaw=180.0 if side else 0.0)

def script(cls, reserve, g):
    return ('wait 120; god; rsr_reload 1; rsr_grab_with 0; rsr_debug 1; give %s; give ammo; use %s; wait 100; '
            '+attack; wait 12; -attack; wait 60; +reload; wait 4; -reload; wait 30; qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 12; '
            'qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 25; qz_ltrigger 0; wait 40; quit'
            % (cls, cls, rig.lpose(0, 40, -30), at(g, g['M'] + 3), at(g, g['M'] * 0.5), at(g, 0)))

if __name__ == '__main__':
    tag, mod, setpk3, guns = sys.argv[1:5]
    files = [os.path.join(DATA, mod) if not os.path.isabs(mod) else mod, setpk3 if os.path.isabs(setpk3) else os.path.join(DATA, setpk3), PROBE]
    bl = '%s/%s_boot.log' % (OUT, tag)
    boot = open(bl, errors='replace').read() if os.path.exists(bl) and '--reboot' not in sys.argv else run(tag + '_boot', files, 'wait 90; quit', 120)
    g = tables(boot)
    print('tables: %d RSR slots dumped; errors: %s' % (len(g), [l for l in boot.splitlines() if re.search(r'Script error|VM abort', l)][:3]))
    for spec in [x for x in guns.split(',') if x]:
        cls, reserve, slot = spec.split(':'); slot = int(slot)
        if slot not in g: print('%-12s slot %d NOT IN TABLES' % (cls, slot)); continue
        t = run('%s_%s' % (tag, cls), files, script(cls, reserve, g[slot]))
        ph = re.findall(r'rsr t\d+ gun (\d+): (\w+) -> (\w+)', t)
        trail = ([ph[0][1]] + [b for _, a, b in ph]) if ph else []
        d = []
        for x in trail:
            if not d or d[-1] != x: d.append(x)
        trail = d
        gun_seen = sorted(set(int(i) for i, _, _ in ph))
        ws = re.findall(r'B22 WS (\d+) gun \d+ (\w+) spr (-?\d+) frame (\d+) statespr (-?\d+)\.(\d+)', t)
        sprs = sorted(set(int(a) for _, _, a, _, _, _ in ws)); dropped = [(int(tt), ph) for tt, ph, a, _, b, _ in ws if a == b]
        shots = re.findall(r'B22 SHOT \d+ \w+ (\d+)', t)
        errs = [l for l in t.splitlines() if re.search(r'VM abort|Script error|exception', l)][:3]
        refused = re.findall(r'rsr t\d+: reload refused.*', t)[:1]
        print('%-12s slot %d: %-55s | shots %s | reload tics logged %d, weapon layer sprite(s) %s, tics on the mod 2D sprite %d %s | %s %s' % (
            cls, slot, '>'.join(trail) or 'NO PHASES', ','.join(shots), len(ws), sprs, len(dropped), dropped[:3] if dropped else '',
            refused or '', errs or ''), flush=True)
