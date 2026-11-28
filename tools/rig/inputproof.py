"""TEST ONLY: prove the rig's input paths on the engine (QuestZDoom 17.3, tools/rig glue), with the probe in probe_input/.

  python3 tools/rig/inputproof.py roll  [--run]   hand roll -> AttackRoll / OffhandRoll (qz_aimroll 0 and 1, both
                                                   hands, right- and left-handed)
  python3 tools/rig/inputproof.py turn  [--run]   the engine's snap turn and smooth turn from the fake sticks, the
                                                   head's yaw, left-handed, grip held; qz_hz pacing
  python3 tools/rig/inputproof.py menu  [--run]   main menu and a mod's yes/no through the fake controller buttons
                                                   and through rig_key; KeyBindings.SetBind on Yes; the bound key pressed
  python3 tools/rig/inputproof.py check <roll|turn|menu> <log>   check a log made elsewhere

Without --run it prints the console script (for rig.py run(..., script) or any launcher). With --run it zips
probe_input/ to $B22_BUILD/probe_input.pk3, runs the engine in a throwaway copy of the rig ($B22_RIG, else
tools/rig/bin) on $B22_IWAD (else $RSQ_GAMEDATA/doom2.wad) with no other pack, writes $B22_BUILD/logs/input_<kind>.log,
prints the table and exits 1 if a check fails. RIG_LOCK=<file> runs it under flock -o -x (shared machines).
"""
import os, re, shutil, subprocess, sys, tempfile, zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.dirname(HERE)); import depot as _DP
B = os.environ.get('B22_BUILD', HERE + '/build')
RIG = os.environ.get('B22_RIG', HERE + '/bin')
IWAD = os.environ.get('B22_IWAD', os.path.join(_DP.GAMEDATA, 'doom2.wad'))

# ---- roll -------------------------------------------------------------------------------------------------
ROLLS = [0, 30, 45, 90, -60, 135, -170]
def roll_script():
    s = ['wait 30']
    n = 0
    for scheme in (0, 10):
        for aim in (0, 1):
            s += ['vr_control_scheme %d' % scheme, 'qz_aimroll %d' % aim]
            cases = [((30, 0, r), (30, 0, -r // 2 if r else 0)) for r in ROLLS] + [((60, 30, 45), (10, -20, -90))]
            for rh, lh in cases:
                s += ['qz_rhand "0.25 1.3 -0.3 %g %g %g"' % rh, 'qz_lhand "-0.25 1.3 -0.3 %g %g %g"' % lh, 'wait 6',
                      'echo ROLLCASE %d scheme %d aimroll %d rhand %g %g %g lhand %g %g %g' % ((n, scheme, aim) + rh + lh),
                      'netevent rp_pose', 'qz_state', 'wait 6']
                n += 1
    return '; '.join(s + ['vr_control_scheme 0', 'qz_aimroll 0', 'quit'])

def _d(a, b): return abs((a - b + 180) % 360 - 180)

def roll_check(t):
    bad = 0; rows = 0
    for i, l in enumerate(t):
        m = re.match(r'ROLLCASE (\d+) scheme (\d+) aimroll (\d) rhand (\S+) (\S+) (\S+) lhand (\S+) (\S+) (\S+)', l)
        if not m: continue
        case, scheme, aim = int(m[1]), int(m[2]), int(m[3])
        rh, lh = tuple(map(float, m.groups()[3:6])), tuple(map(float, m.groups()[6:9]))
        rp = next(x for x in t[i + 1:] if x.startswith('RP t'))
        f = {k: float(v) for k, v in re.findall(r'\b(AA|AP|AR|OA|OP|OR) (-?[\d.]+)', rp)}
        dom, off = (rh, lh) if scheme == 0 else (lh, rh)		# vr_control_scheme 10: the left hand holds the gun
        exact = _d(f['AR'], dom[2]) < 0.01 and _d(f['OR'], off[2]) < 0.01
        py = all(_d(a, b) < 0.01 for a, b in ((f['AP'], dom[0] - 30), (f['AA'], dom[1] - 90), (f['OP'], off[0] - 30), (f['OA'], off[1] - 90)))
        ok = (exact and py) if aim else True
        bad += not ok; rows += 1
        print('case %2d scheme %2d aimroll %d | gun hand p%g y%g r%g -> AP %7.2f AA %7.2f AR %8.2f | off hand p%g y%g r%g -> OP %7.2f OA %7.2f OR %8.2f | roll exact %-3s pitch/yaw as set %-3s%s' % (
            case, scheme, aim, *dom, f['AP'], f['AA'], f['AR'], *off, f['OP'], f['OA'], f['OR'], 'YES' if exact else 'no', 'YES' if py else 'no', '' if ok else '  <-- FAIL'))
    print('ROLL: %d cases, %d qz_aimroll-1 case(s) failing' % (rows, bad))
    return rows == 32 and bad == 0

# ---- turn -------------------------------------------------------------------------------------------------
def _mark(tag, exp): return ['wait 4', 'echo TURN %s | expect %s' % (tag, exp), 'netevent rp_pose', 'qz_state', 'wait 6']
def _flick(stick, x, tag, exp): return ['%s "%g 0"' % (stick, x), 'wait 4', '%s "0 0"' % stick] + _mark(tag, exp)
def nlf(v):		# hw_vrmodes.cpp nonLinearFilter: deadzone 0.1, power 2.2
    a = min(abs(v), 1.0)
    return 0.0 if a <= 0.1 else ((a - 0.1) / 0.9) ** 2.2 * (1 if v > 0 else -1)
def turn_script():
    s = ['wait 30', 'vr_control_scheme 0', 'qz_hz 0', 'qz_rgrip 0'] + _mark('start', 'none')
    for snap in (45, 30, 90):
        s += ['vr_snapTurn %d' % snap]
        s += _flick('qz_rstick', 1, 'snap %d right' % snap, -snap) + _flick('qz_rstick', 1, 'snap %d right' % snap, -snap)
        s += _flick('qz_rstick', -1, 'snap %d left' % snap, snap)
    s += ['vr_snapTurn 45']
    s += _flick('qz_rstick', 0.65, 'snap 45 right at x 0.65 (over 0.6)', -45) + _flick('qz_rstick', 0.55, 'snap 45 right at x 0.55 (under 0.6)', 0)
    s += ['qz_rgrip 1'] + _flick('qz_rstick', 1, 'snap 45 right, gun-hand grip held', 0) + ['qz_rgrip 0']
    s += ['qz_rstick "1 0"', 'wait 30', 'qz_rstick "0 0"'] + _mark('snap 45 right held 30 tics', -45)
    s += ['vr_control_scheme 10'] + _flick('qz_rstick', 1, 'left-handed: right stick', 0) + _flick('qz_lstick', 1, 'left-handed: left stick right', -45)
    s += ['vr_control_scheme 0']
    s += ['qz_hmd "0 1.6 0 0 90 0"'] + _mark('head yaw 90 (left)', 90) + ['qz_hmd "0 1.6 0 0 0 0"'] + _mark('head yaw back to 0', -90)
    for hz in (72, 0):
        for x in (1.0, -0.6):
            s += ['vr_snapTurn 5', 'qz_hz %d' % hz] + _mark('smooth hz %d x %g before' % (hz, x), 'smooth')
            s += ['echo SMOOTH hz %d x %g start' % (hz, x), 'qz_state', 'qz_rstick "%g 0"' % x, 'wait 35',
                  'echo SMOOTH hz %d x %g end' % (hz, x), 'qz_state', 'qz_rstick "0 0"'] + _mark('smooth hz %d x %g after' % (hz, x), 'smooth')
    return '; '.join(s + ['vr_snapTurn 45', 'qz_hz 0', 'quit'])

def turn_check(t):
    bad = 0; prev = None; marks = {}
    for i, l in enumerate(t):
        m = re.match(r'TURN (.*) \| expect (\S+)', l)
        if not m: continue
        q = next(x for x in t[i + 1:] if x.startswith('QZSTATE')); r = next(x for x in t[i + 1:] if x.startswith('RP t'))
        ang = float(re.search(r' ang (-?[\d.]+)', r)[1]); sn = float(re.search(r'snapTurn (-?[\d.]+)', q)[1])
        marks[m[1]] = ang
        if prev is not None and m[2] not in ('none', 'smooth'):
            da = ang - prev; ok = abs(da - float(m[2])) < 0.01
            bad += not ok
            print('%-40s player angle %9.2f  moved %+8.2f  expected %+7.2f  %s' % (m[1], ang, da, float(m[2]), 'ok' if ok else '<-- FAIL'))
        prev = ang
    st = {}
    for i, l in enumerate(t):
        m = re.match(r'SMOOTH hz (\d+) x (\S+) (start|end)', l)
        if m:
            q = next(x for x in t[i + 1:] if x.startswith('QZSTATE'))
            st[(m[1], m[2], m[3])] = (int(re.search(r'frame (\d+)', q)[1]), int(re.search(r'QZSTATE t(\d+)', q)[1]))
    for hz, x, w in sorted(k for k in st if k[2] == 'start'):
        (f0, t0), (f1, t1) = st[(hz, x, 'start')], st[(hz, x, 'end')]
        fr = f1 - f0; rate = -5 * nlf(float(x))
        da = marks['smooth hz %s x %s after' % (hz, x)] - marks['smooth hz %s x %s before' % (hz, x)]
        ok = abs(da - rate * fr) <= 2 * abs(rate) + 0.01		# the frame the stick is set in / released in
        if hz != '0': ok = ok and abs(fr / (t1 - t0) * 35 - int(hz)) < 2
        bad += not ok
        print('smooth vr_snapTurn 5 qz_hz %-2s x %-4s held %d tics = %3d frames (%5.1f fps): expected %+.3f deg/frame = %+8.2f, player angle moved %+8.2f (%+.3f/frame) %s' % (
            hz, x, t1 - t0, fr, fr / (t1 - t0) * 35, rate, rate * fr, da, da / fr, 'ok' if ok else '<-- FAIL'))
    print('TURN: %d check(s) failing' % bad)
    return bad == 0 and len(st) == 8

# ---- menu -------------------------------------------------------------------------------------------------
def _press(cvar, v, tag): return ['echo STEP %s' % tag, '%s %s' % (cvar, v), 'wait 3', '%s 0' % cvar, 'wait 8']
def _stick(y, tag): return ['echo STEP %s' % tag, 'qz_rstick "0 %g"' % y, 'wait 3', 'qz_rstick "0 0"', 'wait 8']
def _key(k, tag): return ['echo STEP %s' % tag, 'rig_key %s' % k, 'wait 8']
MENU_BUTTON, BTN_A, BTN_B = 0x100000, 1, 2	# xrButton_Enter (the menu button), xrButton_A, xrButton_B
def menu_script():
    s = ['wait 30']
    # 1. the Quest's own buttons: left menu button, right stick, A, B (VrInputDefault.cpp -> Joy_GenerateButtonEvents)
    s += _press('qz_lbuttons', MENU_BUTTON, 'ctrl: menu button opens the main menu') + _stick(-1, 'ctrl: right stick down')
    s += _press('qz_rbuttons', BTN_A, 'ctrl: A selects') + _stick(-1, 'ctrl: right stick down')
    s += _press('qz_rbuttons', BTN_B, 'ctrl: B back') + _press('qz_rbuttons', BTN_B, 'ctrl: B closes')
    s += ['echo STEP ctrl: openmenu RigProbeMenu', 'openmenu RigProbeMenu', 'wait 8']
    s += _press('qz_rbuttons', BTN_A, 'ctrl: A on row 0 opens the yes/no') + _stick(-1, 'ctrl: right stick down IN the yes/no')
    s += _stick(1, 'ctrl: right stick up') + _press('qz_rbuttons', BTN_A, 'ctrl: A on row 0 opens the yes/no again')
    s += _press('qz_rbuttons', BTN_A, 'ctrl: A answers (Yes is selected)') + _press('qz_rbuttons', BTN_B, 'ctrl: B closes')
    s += ['echo STEP ctrl: bind k', 'bind k', 'echo STEP ctrl: unbind k', 'unbind k', 'bind k', 'wait 3']
    # 2. rig_key: one key event each
    s += _key('Escape', 'key: Escape opens the main menu') + _key('Axis4Minus', 'key: Axis4Minus') + _key('Pad_A', 'key: Pad_A selects')
    s += _key('Pad_B', 'key: Pad_B back') + _key('Pad_B', 'key: Pad_B closes')
    s += ['echo STEP key: openmenu RigProbeMenu', 'openmenu RigProbeMenu', 'wait 8']
    s += _key('Axis4Minus', 'key: Axis4Minus to the option row') + _key('Pad_A', 'key: Pad_A on the option row') + ['rigp_opt']
    s += _key('Axis4Plus', 'key: Axis4Plus back to row 0') + _key('Pad_A', 'key: Pad_A opens the yes/no')
    s += _key('Axis4Minus', 'key: Axis4Minus to No') + _key('Axis4Plus', 'key: Axis4Plus to Yes') + _key('Pad_A', 'key: Pad_A answers')
    s += _key('Pad_B', 'key: Pad_B closes') + ['echo STEP key: bind k', 'bind k', 'echo STEP key: K pressed in game', 'rig_key K', 'wait 5']
    return '; '.join(s + ['rigp_opt false', 'unbind k', 'quit'])

MENU_EXPECT = [	# (STEP prefix, the RPM menu after it, or a line that must follow before the next STEP)
    ('ctrl: menu button opens', "ListMenu 'Mainmenu' row 1"), ('ctrl: right stick down', "ListMenu 'Mainmenu' row 2"),
    ('ctrl: A selects', "OptionMenu 'OptionsmenuSimple' row 0"), ('ctrl: right stick down', "OptionMenu 'OptionsmenuSimple' row 1"),
    ('ctrl: B back', "ListMenu 'Mainmenu' row 2"), ('ctrl: B closes', 'none'),
    ('ctrl: openmenu', "OptionMenu 'RigProbeMenu' row 0"), ('ctrl: A on row 0 opens the yes/no', 'RigAskBox selection 0'),
    ('ctrl: right stick down IN the yes/no', "OptionMenu 'RigProbeMenu' row 1"),	# the Quest stick also sends MWheelDown: the box closes
    ('ctrl: right stick up', "OptionMenu 'RigProbeMenu' row 0"), ('ctrl: A on row 0 opens the yes/no again', 'RigAskBox selection 0'),
    ('ctrl: A answers', 'RIGMENU answered YES'), ('ctrl: B closes', 'none'), ('ctrl: bind k', '"k" = "echo RIGPROBE_BOUND"'),
    # the main menu reopens on the row it was left on (its descriptor keeps mSelectedItem): Options, row 2
    ('key: Escape', "ListMenu 'Mainmenu' row 2"), ('key: Axis4Minus', "ListMenu 'Mainmenu' row 3"),
    ('key: Pad_A selects', "LoadMenu 'Loadgamemenu'"), ('key: Pad_B back', "ListMenu 'Mainmenu' row 3"),
    ('key: Pad_B closes', 'none'), ('key: openmenu', "OptionMenu 'RigProbeMenu' row 0"),
    ('key: Axis4Minus to the option row', "OptionMenu 'RigProbeMenu' row 1"), ('key: Pad_A on the option row', '"rigp_opt" is "true"'),
    ('key: Axis4Plus back', "OptionMenu 'RigProbeMenu' row 0"), ('key: Pad_A opens the yes/no', 'RigAskBox selection 0'),
    ('key: Axis4Minus to No', 'RigAskBox selection 1'), ('key: Axis4Plus to Yes', 'RigAskBox selection 0'),
    ('key: Pad_A answers', 'RIGMENU answered YES'), ('key: Pad_B closes', 'none'),
    ('key: bind k', '"k" = "echo RIGPROBE_BOUND"'), ('key: K pressed in game', 'RIGPROBE_BOUND')]

def menu_check(t):
    steps = []
    for l in t:
        if l.startswith('STEP '): steps.append([l[5:], []])
        elif steps: steps[-1][1].append(l)
    bad = 0; k = 0
    for pre, want in MENU_EXPECT:
        while k < len(steps) and not steps[k][0].startswith(pre): k += 1
        if k == len(steps):
            print('%-45s MISSING  <-- FAIL' % pre); bad += 1; break
        body = steps[k][1]
        got = [x for x in body if x.startswith('RPM ') or x.startswith('RIGMENU') or x.startswith('"') or x == 'RIGPROBE_BOUND']
        ok = any((x.split(' menu ', 1)[1].startswith(want) if x.startswith('RPM ') else x.startswith(want)) for x in got)
        bad += not ok
        print('%-45s %-48s %s' % (steps[k][0][:45], ' / '.join(x.split(' menu ', 1)[1] if x.startswith('RPM ') else x for x in got)[:48] or '-', 'ok' if ok else '<-- FAIL'))
        k += 1
    fatal = [l for l in t if 'outside of menu code' in l or 'FATAL' in l or 'VM execution aborted' in l]
    bad += len(fatal)
    for l in fatal: print('FATAL LINE: ' + l)
    print('MENU: %d check(s) failing' % bad)
    return bad == 0

KINDS = {'roll': (roll_script, roll_check), 'turn': (turn_script, turn_check), 'menu': (menu_script, menu_check)}

def run(kind):
    os.makedirs(B + '/logs', exist_ok=True)
    pk3 = B + '/probe_input.pk3'
    with zipfile.ZipFile(pk3, 'w', zipfile.ZIP_DEFLATED) as z:
        for f in sorted(os.listdir(HERE + '/probe_input')):
            z.write(os.path.join(HERE, 'probe_input', f), f)
    for f in (IWAD, RIG + '/qz', RIG + '/qzdoom'):
        if not os.path.exists(f): sys.exit('inputproof: missing ' + f)
    log = os.path.abspath('%s/logs/input_%s.log' % (B, kind))
    if os.path.exists(log): os.remove(log)
    tmp = tempfile.mkdtemp(prefix='inputproof_')
    try:
        rig = os.path.join(tmp, 'rig'); shutil.copytree(RIG, rig, symlinks=True)	# the engine rewrites its ini: never the real one
        cmd = ['timeout', '600', rig + '/qz', '-iwad', os.path.abspath(IWAD), '-file', os.path.abspath(pk3), '-nosound', '-warp', '1',
               '-skill', '3', '+logfile', log, '+' + KINDS[kind][0]()]
        if os.environ.get('RIG_LOCK'): cmd = ['flock', '-o', '-x', os.environ['RIG_LOCK']] + cmd
        with open(log + '.out', 'w') as fo:
            rc = subprocess.run(cmd, stdout=fo, stderr=subprocess.STDOUT, cwd=rig, env=dict(os.environ, QZ_RES=os.environ.get('QZ_RES', '200'),
                                EGL_PLATFORM='surfaceless', LIBGL_ALWAYS_SOFTWARE='1')).returncode
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    print('rc %d, log %s' % (rc, log))
    return log

if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['check']:
        sys.exit(0 if KINDS[a[1]][1](open(a[2], errors='replace').read().splitlines()) else 1)
    if not a or a[0] not in KINDS: sys.exit(__doc__)
    if '--run' not in a:
        print(KINDS[a[0]][0]()); sys.exit(0)
    log = run(a[0])
    sys.exit(0 if KINDS[a[0]][1](open(log, errors='replace').read().splitlines()) else 1)
