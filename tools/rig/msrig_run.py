"""TEST ONLY: a ModelSwapper set on the rig -- every gun given, fired and reloaded, the weapon layer watched.

    python3 -B tools/rig/msrig_run.py <name> <mod.pk3> <set.pk3> "Class1,Class2,..." [extra console cmds]

Real QuestZDoom 17.3 (tools/rig/bin/qz, PINS), OpenXR path, doom2 -> mod -> set -> msrig overlay, MAP01, god.
Data in /home/claude/rig/packs (the owner's, never committed). One engine at a time (flock /home/claude/rig.lock).
Output: tools/rig/runs/<name>.log (MSRIG lines), runs/<name>/f*.ppm (a frame every 35 rendered frames).
The rig engine reads/writes bin/config/qzdoom.ini relative to its cwd (ignores -config): restored from git
before and after.
"""
import os, sys, subprocess, zipfile
H = os.path.dirname(os.path.abspath(__file__)); RIG = os.path.join(H, 'bin'); DATA = '/home/claude/rig/packs'
name, mod, setpk3, guns = sys.argv[1:5]; extra = sys.argv[5] if len(sys.argv) > 5 else ''
out = os.path.join(H, 'runs'); os.makedirs(os.path.join(out, name), exist_ok=True)
ov = os.path.join(out, 'msrig_overlay.pk3'); log = os.path.join(out, name + '.log')
with zipfile.ZipFile(ov, 'w', zipfile.ZIP_DEFLATED) as z:
    z.writestr('zscript/rig/msrig.zs', open(os.path.join(H, 'msrig.zs')).read())
    z.writestr('ZSCRIPT.msrig', 'version "4.10"\n#include "zscript/rig/msrig.zs"\n')
    z.writestr('MAPINFO.msrig', 'gameinfo { AddEventHandlers = "MSRIG_Test" }\n')
    z.writestr('CVARINFO.msrig', 'user string msrig_guns = "";\nuser string qzt_rhand = "";\nuser string qzt_lhand = "";\n'
               'user float qzt_rtrigger = -1;\nuser float qzt_rgrip = -1;\nuser float qzt_ltrigger = -1;\nuser float qzt_lgrip = -1;\n')
ini = os.path.join(RIG, 'config', 'qzdoom.ini')
def reset_ini(): subprocess.call(['git', '-C', os.path.dirname(os.path.dirname(H)), 'checkout', '--', os.path.relpath(ini, os.path.dirname(os.path.dirname(H)))], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
reset_ini()
# THE RELOAD IS PRESSED FROM THE CONSOLE: WorldTick runs after PlayerThink, so a BT_RELOAD written into the
# usercmd from the handler is never seen by P_CheckWeaponButtons (measured: buttons=0x40 in the log, no reload).
# `+reload` / `-reload` are console button commands; the harness's phases are fixed at t0 = 70 + 420 i, RELOAD at
# dt 260..268, so the console script presses them at absolute times. Console waits are in tics.
n = len(guns.split(',')); secs = 120 + n * 420 // 35 * 2 + 60
cmds = [(40, 'god'), (41, 'msrig_guns "%s"' % guns)] + ([(42, extra.strip().rstrip(';'))] if extra.strip() else [])
for i in range(n):
    cmds += [(70 + 420 * i + 261, '+reload'), (70 + 420 * i + 269, '-reload')]
cmds += [(100 + n * 420 + 40, 'quit')]
cmds.sort(); parts = []; now = 0
for t, c in cmds:
    if t > now: parts.append('wait %d' % (t - now)); now = t
    parts.append(c)
script = '; '.join(parts)
env = dict(os.environ, QZ_RES='480', QZ_DUMP_EVERY='35', QZ_DUMP_DIR=os.path.join(out, name))
argv = ['flock', '-o', '-x', '/home/claude/rig.lock', 'timeout', str(max(900, secs * 4)), 'xvfb-run', '-a', os.path.join(RIG, 'qz'),
        '-iwad', os.path.join(DATA, 'doom2.wad'), '-file', mod if os.path.isabs(mod) else os.path.join(DATA, mod),
        setpk3 if os.path.isabs(setpk3) else os.path.join(DATA, setpk3), ov,
        '-nosound', '-nomusic', '+logfile', log, '+map', 'MAP01', '+' + script]
r = subprocess.call(argv, cwd=RIG, env=env, stdout=open(os.path.join(out, name + '.out'), 'w'), stderr=subprocess.STDOUT)
reset_ini()
print('exit', r, '->', log)
