"""TEST ONLY: drive a pack in the QuestZDoom 17.3 rig (real QZD 17.3, OpenXR mode, poses from cvars).

Never ships. run(name, script) launches the load order the depot's
CLAUDE.md names -- doom2 -> brutal22test6 -> BD_VoxelPack -> the pack -- plus the test probe, with
one chained console script, and returns the log.
"""
import os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
B = os.environ.get('B22_BUILD', HERE + '/build')		# setup.sh builds everything here
RIG = os.environ.get('B22_RIG', HERE + '/bin')	# QuestZDoom 17.3 only: the prebuilt tools/rig/bin, or B22_RIG (e.g. build/rig from setup.sh build)
if not os.path.exists(os.path.join(RIG, 'qzdoom')):
	sys.exit('rig.py: no rig at %s. tools/rig/bin is in git (prebuilt QuestZDoom 17.3); '
	         'or run: sh tools/rig/setup.sh build and set B22_RIG=tools/rig/build/rig' % RIG)
# the owner's game data, never committed: B22_IWAD / B22_BD22 / B22_VOX, else $RSQ_GAMEDATA/<name>
# (RSQ_GAMEDATA defaults to a 'gamedata' folder beside the Depot checkout; tools/depot.py)
sys.path.append(os.path.dirname(HERE)); import depot as _DP
IWAD = os.environ.get('B22_IWAD', os.path.join(_DP.GAMEDATA, 'doom2.wad'))
BD22 = os.environ.get('B22_BD22', os.path.join(_DP.GAMEDATA, 'brutal22test6.pk3'))
VOX = os.environ.get('B22_VOX', os.path.join(_DP.GAMEDATA, 'BD_VoxelPack.pk3'))
PROBE = B + '/probe.pk3'
OUT = B + '/logs'
PK3 = os.environ.get('B22_PK3', B + '/BD22Q_now.pk3')

# gun frame (cm, F L U) -> stage pose for the OFF hand, oriented like the gun hand (pitch 30 = level
# after vr_weaponRotate -30), so the off hand's frame IS the gun's frame and OffDirInGun(axis) = axis.
RHAND = (0.25, 1.3, -0.3)

def lpose(F, L, U, pitch=30.0, yaw=0.0, roll=0.0):
    return '%.4f %.4f %.4f %.1f %.1f %.1f' % (RHAND[0] - L / 100.0, RHAND[1] + U / 100.0,
                                             RHAND[2] - F / 100.0, pitch, yaw, roll)

def pack_cvars(pk3):
    """(name, default) for every cvar the pack's CVARINFO lumps declare."""
    import re, zipfile
    out = []
    with zipfile.ZipFile(pk3) as z:
        for n in z.namelist():
            if os.path.basename(n).upper().startswith('CVARINFO'):
                t = re.sub(r'//[^\n]*', '', z.read(n).decode('latin-1'))
                out += re.findall(r'\b(?:user|server)\s+(?:noarchive\s+|cheat\s+|latch\s+|nosave\s+)*\w+\s+(\w+)\s*=\s*"?([^";]*)"?\s*;', t)
    return out

def cvar_report(cv, text):
    """The engine's value of each pack cvar at start ('"x" is "v"'); a saved ini value that hides a
    feature (the owner's rsq_hands=false, 2026-10-27) shows here instead of hiding silently."""
    import re
    got = dict(re.findall(r'"(\w+)" is "([^"]*)"', text))
    def norm(v):
        v = v.strip().lower()
        try: return float({'true': 1, 'false': 0}.get(v, v))
        except ValueError: return v
    off = [(n, got[n], d) for n, d in cv if n in got and norm(got[n]) != norm(d)]
    hid = [n for n, v, d in off if norm(v) == 0 and norm(d) != 0]	# a feature on by default, saved off
    return 'RIG CVARS %d of %d read; FEATURES SAVED OFF: %s; not at default: %s' % (
        sum(n in got for n, _ in cv), len(cv), ', '.join(hid) or 'none',
        '; '.join('%s=%s (default %s)' % o for o in off) or 'none')

def ini_report(cv, ini):
    """Before launch: the pack cvars a saved ini sets away from the pack's default. The rig and the
    owner's qzdoom ini both keep them; a hidden feature (rsq_hands=false) shows here."""
    import re
    got = {}
    if os.path.exists(ini):
        for k, v in re.findall(r'^(\w+)=(.*)$', open(ini, errors='replace').read(), re.M):
            got[k.lower()] = v
    t = cvar_report(cv, '\n'.join('"%s" is "%s"' % (n, got[n.lower()]) for n, _ in cv if n.lower() in got))
    return t.replace('RIG CVARS', 'INI CVARS %s:' % ini, 1)

def run(name, script, secs=150, extra=()):
    cv = pack_cvars(PK3) if os.path.exists(PK3) else []
    if cv:
        print(ini_report(cv, RIG + '/config/qzdoom.ini'), file=sys.stderr)
    script = ''.join('%s; ' % n for n, _ in cv) + script	# the console prints each value at start
    os.makedirs(OUT, exist_ok=True)
    log = '%s/%s.log' % (OUT, name)
    for f in (log, log + '.out'):
        if os.path.exists(f):
            os.remove(f)
    files = [BD22, VOX, PK3] + ([] if os.environ.get('B22_NOPROBE') else [PROBE]) + list(extra)
    files = [os.path.abspath(f) for f in files]	# the engine runs from RIG, not from here
    for f in [IWAD] + files:
        if not os.path.exists(f):
            raise SystemExit('missing ' + f)
    cmd = ['timeout', str(secs), RIG + '/qz', '-iwad', IWAD, '-file'] + files + \
          ['-nosound', '-warp', '1', '-skill', '3', '+logfile', log, '+' + script]
    with open(log + '.out', 'w') as fo:
        rc = subprocess.run(cmd, stdout=fo, stderr=subprocess.STDOUT, cwd=RIG,
                            env=dict(os.environ, QZ_RES=os.environ.get('QZ_RES','200'), EGL_PLATFORM='surfaceless',
                                     LIBGL_ALWAYS_SOFTWARE='1')).returncode
    text = ''
    for f in (log, log + '.out'):
        if os.path.exists(f):
            text += open(f, errors='replace').read()
    if cv:
        print(cvar_report(cv, text), file=sys.stderr)
    return rc, text

if __name__ == '__main__':
    if sys.argv[1:2] == ['--cvars']:		# rig.py --cvars <pk3> <ini>: check any ini (e.g. the owner's) without a run
        print(ini_report(pack_cvars(sys.argv[2]), sys.argv[3]))
        sys.exit(0)
    rc, t = run(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 150)
    print('rc', rc)
    print(t[-4000:])
