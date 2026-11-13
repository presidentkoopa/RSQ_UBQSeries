"""The one rig suite (CLAUDE.md rule 4/5): every weapon of the built tree, unattended, on the QZD 17.3 rig.

    python3 tools/suite.py            -> out/suite/<gun>.log (the raw logs), out/SUITE_REPORT.md, out/suite.json
                                         (passed: true only if every check of every weapon passed, on this exact tree)
    python3 tools/suite.py RSQGW_Beretta -> one weapon only (never writes a pass: a pk3 needs the full suite)

Per weapon, one run (Freedoom 2 MAP01, god, notarget, the VR controllers as cvars):
  pickup      a fresh one picked up (Weapon.TryPickup: a Ready frame with an image)
  raise       it comes up in the hand
  fire        a shot goes out (hitscan, a True Bullets round, or its projectile) and the gun's rounds go down
  alt         its alt fire does what PLAN.md says
  kick        the Quick Kick key runs the kick
  stock       Reloading = Stock, emptied: the reload key fills it (to one less if it keeps one chambered)
  hand        Reloading = VR, emptied: the robot off hand reloads it (magazine / pump / break-open), rounds counted
  flick       Reloading = Flick, emptied: a flick of the gun hand reloads it
  dual        (dual guns) its off-hand version goes into the off hand and fires on the off trigger
and everywhere: no script error, no VM abort."""
import json, os, re, shutil, sys, tempfile, zipfile
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
OUT = os.path.join(ROOT, 'out'); TREE = os.path.join(OUT, 'tree'); LOGS = os.path.join(OUT, 'suite')
RIG = os.environ.get('RSQ_RIG', '/home/claude/presidentkoopa/rsq_meshturbator/rig')
sys.path.insert(0, RIG); sys.path.insert(0, HERE)
import rig
from build import pack

RH = 'qz_rhand "0.25 1.3 -0.3 0 0 0"'
LH = 'qz_lhand "-0.25 1.3 -0.3 0 0 0"'
LAWAY = 'qz_lhand "-0.45 0.9 0.0 0 0 0"'	# the off hand down at the side: near the gun the engine steadies it (two-hand grip) and the gun cannot flick
# a flick of the gun hand (rsq/flick.zs: the barrel must come from above -15 degrees, drop 45 within 4 tics, end below
# -40). The rig's rest pose (pitch 0) already reads -30, below BD22 VR's re-arm line, so the hand is raised first (pitch
# +40 is the barrel up), then snapped down (-70) and brought back. ELEV logs the elevation the flick reads.
FLICK = 'set rsprobe_elev 1; qz_rhand "0.25 1.3 -0.3 40 0 0"; wait 8; qz_rhand "0.25 1.3 -0.3 -70 0 0"; wait 3; qz_rhand "0.25 1.3 -0.3 0 0 0"; wait 8; set rsprobe_elev 0; '

# class: reload kind, magazine size from empty (chambered: one less), the alt check, fire hold tics, dual
G = {
    'RSQGW_Knuckle':     dict(kind=None, cap=None, alt=None, hold=3),
    'RSQGW_ModChainsaw': dict(kind=None, cap=None, alt=None, hold=70, saw=True),
    'RSQGW_Beretta':     dict(kind='mag', cap=10, alt='shot', hold=3, dual=True),		# alt: the 3-round burst
    'RSQGW_ARifle':      dict(kind='mag', cap=30, alt='burst', hold=3, dual=True),	# alt: full auto <-> 3-round burst
    'RSQGW_Minigun':     dict(kind='mag', cap=150, alt=None, hold=40),
    'RSQGW_Rlauncher':   dict(kind='mag', cap=5, alt=None, hold=3, fire=('missile', 'RSQGW_Rocket2')),
    'RSQGW_PlasRifle':   dict(kind='mag', cap=60, alt='rail', hold=3, fire=('missile', 'RSQGW_Plasma')),
    'RSQGW_BFG9K':       dict(kind=None, cap=None, alt=None, hold=3, fire=('missile', 'BFGBall'), noreload=True),
    'RSQGW_Riotgun':     dict(kind='pump', cap=8, alt='shot', hold=3),
    'RSQGW_DoubleSG':    dict(kind='break', cap=2, alt='shot', hold=3),
}
ROBOT = {'mag': 2, 'pump': 3, 'break': 1}

def mark(m): return 'echo MARK_%s; ' % m

def script(cls, g):
    # the pack's own defaults (the rig's saved config holds other packs' choices: rsa_sg_slug false, rsm_ammo 0,
    # rsq_ballistics 0 were found there); logs on
    s = 'set rsa_sg_slug 1; set rsm_ammo 1; set rsq_ballistics 1; set rsq_switch_log 1; '
    s += 'set rsr_debug 1; god; notarget; give ammo; %s; %s; wait 40; ' % (RH, LH)
    s += mark('PICKUP') + 'take %s; wait 5; netevent probe:%s; wait 5; ' % (cls, cls)
    s += mark('RAISE') + 'give %s; wait 2; use %s; wait 70; netevent probe_ammo; wait 2; ' % (cls, cls)
    if g.get('saw'):
        s += 'netevent probe_spawn:DoomImp 37; wait 5; '
    # BD22 VR's pump (rsr_pump.zs): not worked by the hand, firing again pumps it itself -- so the pump gun fires twice
    # (BD22 VR rsr_pump.zs PumpTick: "fire: the set's own pump"): the 2nd pull pumps, the 3rd fires
    # and a 4th pull pumps it again, so the gun is ready for the alt fire
    again = ('wait 30; +attack; wait 3; -attack; wait 40; +attack; wait 3; -attack; wait 60; +attack; wait 3; -attack; wait 40; ') if g['kind'] == 'pump' else ''
    pumpit = 'wait 30; +attack; wait 3; -attack; wait 40; ' if g['kind'] == 'pump' else ''	# after the slug: a pull pumps it
    s += mark('FIRE') + 'netevent probe_ammo; wait 2; +attack; wait %d; -attack; wait 60; ' % g['hold'] + again + 'netevent probe_ammo; wait 2; '
    if g.get('saw'):
        s += 'kill monsters; wait 5; '
    if g['kind'] and not g.get('fire') and g['kind'] != 'break' or cls == 'RSQGW_DoubleSG':	# the hitscan guns: True Bullets off too
        s += mark('FIREHS') + 'set sv_rsq_true_bullets 0; wait 2; netevent probe_ammo; wait 2; +attack; wait %d; -attack; wait 60; ' % g['hold'] + again + 'netevent probe_ammo; wait 2; set sv_rsq_true_bullets 1; give ammo; wait 2; '	# refilled for the alt fire
    if g['alt'] == 'lock':
        s += 'set rsq_switch_log 1; netevent probe_spawn:DoomImp 160; wait 5; '
    if g['alt'] == 'burst':	# switch to burst, hold the trigger long: three rounds and it stops; then back to full auto
        s += mark('ALT') + 'give ammo; wait 2; +altattack; wait 3; -altattack; wait 20; netevent probe_ammo; wait 2; +attack; wait 60; -attack; wait 20; netevent probe_ammo; wait 2; +altattack; wait 3; -altattack; wait 20; '
    else:
        s += mark('ALT') + 'netevent probe_ammo; wait 2; +altattack; wait 3; -altattack; wait 90; netevent probe_ammo; wait 2; ' + pumpit
    s += mark('KICK') + 'netevent rsqgw_kick; wait 30; '
    if g['kind']:
        s += mark('STOCK') + 'give ammo; set rsr_reload 0; netevent probe_empty 0; wait 2; netevent probe_ammo; wait 2; +reload; wait 4; -reload; wait 250; netevent probe_ammo; wait 2; '
        s += mark('HAND') + ('set rsr_shell_credit 4; ' if g['kind'] == 'pump' else '') + 'give ammo; set rsr_reload 1; netevent probe_empty 0; wait 2; netevent probe_ammo; wait 2; set rsprobe_robot %d; +reload; wait 4; -reload; wait %d; set rsprobe_robot 0; wait 30; ' % (ROBOT[g['kind']], 3300 if g['kind'] == 'pump' else 1100)	# the pump: 8 shells
        if g['kind'] == 'break':	# shut by a flick of the gun, BD22 VR's way
            s += RH + '; ' + LAWAY + '; wait 20; ' + FLICK + 'wait 30; '
        s += 'netevent probe_ammo; wait 2; ' + RH + '; ' + LH + '; wait 20; '
        if g['kind'] == 'pump':
            s += 'set rsr_shell_credit 1; '
        if g['kind'] == 'pump':	# counted above; then, if it still waits for the pump (the robot may or may not have worked it),
            s += '+attack; wait 3; -attack; wait 40; '	# a trigger pull pumps it itself (BD22 VR) -- no count after this
        if cls == 'RSQGW_DoubleSG':	# BD22 VR: a lone SSG flicks into its own reload
            s += mark('FLICK') + 'give ammo; ' + LAWAY + '; wait 20; netevent probe_empty 0; wait 2; netevent probe_ammo; wait 2; ' + FLICK + 'wait 250; netevent probe_ammo; wait 2; ' + LH + '; wait 10; '
    if g.get('dual'):
        s += 'give RSQ_Off_%s; wait 2; ' % cls
        s += mark('DUAL') + 'netevent rsq_dual; wait 60; netevent probe_ammo; wait 2; qz_ltrigger 1; wait 3; qz_ltrigger 0; wait 40; netevent probe_ammo; wait 2; '
        # BD22 VR: with a gun in each hand, a flick of the main gun reloads it with its own (stock) reload
        s += mark('FLICK') + 'give ammo; netevent probe_empty 0; wait 2; netevent probe_ammo; wait 2; ' + FLICK + 'wait 250; netevent probe_ammo; wait 2; netevent rsq_dual; wait 60; '
    s += mark('END') + 'wait 5; quit'
    return s

def sections(t):
    cur, out = 'START', {'START': []}
    for l in t.splitlines():
        m = re.match(r'MARK_(\w+)', l.strip())
        if m:
            cur = m.group(1); out.setdefault(cur, []); continue
        out[cur].append(l)
    return out

def ammo(lines, hand='main', grp=5):	# grp 5: the rounds in the gun (Ammo2), 3: the reserve (Ammo1)
    r = []
    for l in lines:
        m = re.match(r'AMMO t\d+ %s (\S+) (\S+)=(-?\d+) (\S+)=(-?\d+)' % hand, l)
        if m: r.append(int(m.group(grp)))
    return r

def shots(lines, want=None):
    n = 0
    for l in lines:
        if want and want[0] == 'missile':
            if re.search(r'PROBE t\d+ missile %s$' % want[1], l): n += 1
        elif re.search(r'PROBE t\d+ (hitscan|round )', l): n += 1
    return n

def check(cls, g, t):
    S = sections(t); R = []
    def res(name, ok, why): R.append((name, bool(ok), why))
    errs = [l for l in t.splitlines() if re.search(r'Script error|VM abort|aborted|FATAL', l)]
    res('no script error / VM abort', not errs, '; '.join(e.strip()[:120] for e in errs[:3]) or 'none')
    pk = [l for l in S.get('PICKUP', []) if l.startswith('PICKUP')]
    res('pickup', pk and ' 1 owned 1' in pk[0], pk[0] if pk else 'no PICKUP line')
    up = [l for k in ('PICKUP', 'RAISE') for l in S.get(k, []) if re.match(r'PROBE t\d+ ready %s ' % cls, l)]
    res('raise', up, up[0].strip() if up else 'never in the hand')
    F = S.get('FIRE', [])
    if g.get('saw'):
        cuts = [l for l in F if re.match(r'DMG t\d+ \S+ by RSQGW_SawCut', l)]
        res('fire: the running bar cuts by contact', cuts, '%d cuts by RSQGW_SawCut' % len(cuts))
    elif g.get('noreload'):	# the BFG: fires from the cells carried, 40 a shot
        a = ammo(F, grp=3); n = shots(F, g['fire'])
        res('fire: one %s, 40 cells from the reserve (no magazine)' % g['fire'][1], n >= 1 and len(a) >= 2 and a[0] - a[-1] == 40, '%d shots, cells %s' % (n, ' -> '.join(map(str, a))))
    elif g['kind'] is None:
        st = [l for l in F if re.match(r'STATE t\d+ %s Fire' % cls, l)]
        res('fire: the trigger is free (no blow from the weapon)', shots(F) == 0, '%d shots, Fire state %s' % (shots(F), 'entered' if st else 'not entered'))
    else:
        a = ammo(F); n = shots(F, g.get('fire'))
        need = 2 if g['kind'] == 'pump' else 1	# the pump gun: a second pull pumps it itself and fires again (BD22 VR)
        selfpump = [l for l in F if "fire: the set's own pump" in l]
        res('fire' + (', then a pull pumps it itself (no hand), then it fires again' if need == 2 else ''), n >= need and len(a) >= 2 and a[0] - a[-1] >= need and (need == 1 or selfpump), '%d shots (%s), rounds %s' % (n, (g.get('fire') or ('hitscan/round',))[-1], ' -> '.join(map(str, a))))
    for sec, what in (('FIRE', 'True Bullets on'), ('FIREHS', 'True Bullets off (hitscan)')):
        if sec not in S or g['kind'] is None or g.get('fire'): continue
        fx = [l for l in S[sec] if re.match(r'PROBE t\d+ bfx ', l)]
        res('RS Ballistics impact / flash effects, %s' % what, fx, '%d effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris)' % len(fx))
    A = S.get('ALT', [])
    alt = g['alt']
    if alt is None:
        a = ammo(A)
        res('alt: none (free)', shots(A) == 0 and (len(set(a)) <= 1), '%d shots, rounds %s' % (shots(A), ' -> '.join(map(str, a))))
    elif alt == 'shot':
        a = ammo(A); n = shots(A)
        res('alt (burst / slug / both barrels)', n > 0 and len(a) >= 2 and a[-1] < a[0], '%d shots, rounds %s' % (n, ' -> '.join(map(str, a))))
    elif alt == 'burst':
        a = ammo(A); n = shots(A)
        res('alt: switches to 3-round burst (a long pull fires 3 and stops)', n == 3 and len(a) >= 2 and a[0] - a[-1] == 3, '%d shots, rounds %s' % (n, ' -> '.join(map(str, a))))
    elif alt == 'rail':
        a = ammo(A)
        res('alt: the rail, 20 cells from the magazine', len(a) >= 2 and a[0] - a[-1] == 20, 'rounds %s' % ' -> '.join(map(str, a)))
    K = [l for l in S.get('KICK', []) if re.match(r'STATE t\d+ \S+ (DoKick|AirKick)', l)]
    res('quick kick', K, K[0].strip() if K else 'kick state never entered')
    if g['kind']:
        secs = [('STOCK', 'stock reload'), ('HAND', 'hand reload (robot, %s)' % g['kind'])]
        if g.get('dual') or cls == 'RSQGW_DoubleSG':
            secs.append(('FLICK', 'flick reload (BD22 VR: %s)' % ('a gun in each hand' if g.get('dual') else 'the lone SSG')))
        for sec, what in secs:
            a = ammo(S.get(sec, []))
            back = [l for l in S.get(sec, []) if re.match(r'STATE t\d+ %s Ready' % cls, l)]
            ok = len(a) >= 2 and a[0] == 0 and a[-1] == g['cap'] and back
            res(what, ok, 'rounds %s (want 0 -> %d)%s' % (' -> '.join(map(str, a)), g['cap'], '' if back else ', the gun never came back to Ready'))
    if g['kind'] == 'pump':
        ins = [l for l in S.get('HAND', []) if re.search(r'rsp t\d+ .*shell \d+ home', l)]
        res('Shotgun Shells Per Insert = 4: the tube fills in 2 inserts', 0 < len(ins) <= 2, '%d shells pushed home' % len(ins))
    if g.get('dual'):
        D = S.get('DUAL', [])
        offr = [l for l in D if re.match(r'AMMO t\d+ off RSQ_Off_%s ' % cls, l)]
        ao = ammo(D, 'off'); n = shots(D)
        res('dual: off-hand copy in the off hand, fires on the off trigger', offr and len(ao) >= 2 and ao[-1] < ao[0] and n > 0,
            'off hand %s; off rounds %s; %d shots' % ('RSQ_Off_' + cls if offr else 'not taken', ' -> '.join(map(str, ao)), n))
    return R

def main():
    only = sys.argv[1:]
    fp = open(os.path.join(OUT, 'tree.sha256')).read().strip()
    os.makedirs(LOGS, exist_ok=True)
    tmp = tempfile.mkdtemp()
    pk = os.path.join(tmp, 'gnrc.pk3'); pack(pk)
    probe = os.path.join(tmp, 'probe.pk3'); pack(probe, os.path.join(HERE, 'suite/probe'))
    results = {}
    for cls, g in G.items():
        if only and cls not in only: continue
        name = 'suite_' + cls
        rig.run(name, [pk, probe], script(cls, g), secs=900)
        src = os.path.join(RIG, 'runs', name + '.log')
        t = open(src, errors='replace').read() if os.path.exists(src) else ''
        shutil.copyfile(src, os.path.join(LOGS, cls + '.log')) if os.path.exists(src) else None
        results[cls] = check(cls, g, t)
        bad = [r for r in results[cls] if not r[1]]
        print('%-20s %s' % (cls, 'PASS' if not bad else 'FAIL: ' + ', '.join(r[0] for r in bad)), flush=True)
    shutil.rmtree(tmp)
    allok = all(ok for R in results.values() for _, ok, _ in R) and not only and len(results) == len(G)
    rep = ['# GNRC_Reloaded rig suite', '', 'Tree %s. %s.' % (fp[:16], 'ALL PASSED' if allok else 'NOT PASSED'), '',
           'QuestZDoom 17.3 rig, Freedoom 2 MAP01, god + notarget, controllers driven as cvars. Raw logs: out/suite/<class>.log.', '']
    for cls, R in results.items():
        rep += ['## %s' % cls, '', '| check | result | detail |', '|---|---|---|']
        rep += ['| %s | %s | %s |' % (n, 'pass' if ok else '**FAIL**', w.replace('|', '/')) for n, ok, w in R] + ['']
    open(os.path.join(OUT, 'SUITE_REPORT.md'), 'w').write('\n'.join(rep))
    if not only:
        json.dump(dict(passed=allok, tree=fp, results={c: [list(r) for r in R] for c, R in results.items()}), open(os.path.join(OUT, 'suite.json'), 'w'), indent=1)
    print('suite:', 'PASSED' if allok else 'NOT PASSED', '->', os.path.join(OUT, 'SUITE_REPORT.md'))

if __name__ == '__main__':
    main()
