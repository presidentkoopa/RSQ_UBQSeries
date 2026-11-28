"""TEST ONLY (2026-11-09): pump and break-open VR hand reloads of a ModelSwapper set on the rig (pump.py / brk.py's
method, re-pointed at a mod + MS set).  python3 -B msload.py <tag> <mod> <set> pump <Class> <ShellAmmo> <slot>
                                                python3 -B msload.py <tag> <mod> <set> break <Class> <ShellAmmo>
Prints the RSP/RSB phase lines and the weapon layer's sprite through them (B22 WS lines come from the RSR state only, so
for pump/break the layer is read from the B22 PS line the MS probe adds)."""
import os, re, sys, numpy as np
H = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, H)
import handrot as h, msmags
FAR = '-0.25 1.3 -0.3 30 0 0'
tag, mod, setpk3, kind, cls, ammo = sys.argv[1:7]
files = [os.path.join(msmags.DATA, mod), setpk3, msmags.PROBE]
if kind == 'pump':
    slot = int(sys.argv[7])
    boot = open('%s/%s_boot.log' % (msmags.OUT, tag), errors='replace').read()
    m = re.search(r'B22 PUMP %d port (\S+) (\S+) (\S+) push (\S+) (\S+) (\S+) depth (\S+) shell (\S+) (\S+) (\S+) axis (\S+) (\S+) (\S+) grab (\S+) (\S+) (\S+) pull (\S+) (\S+) (\S+) travel (\S+)' % slot, boot)
    if not m: sys.exit('no B22 PUMP %d in the boot log (re-run msmags with --reboot)' % slot)
    v = [float(x) for x in m.groups()]
    PORT, PUSH, DEPTH, SHELL, AXIS, GRAB, PULL, TRAVEL = tuple(v[0:3]), tuple(v[3:6]), v[6], tuple(v[7:10]), tuple(v[10:13]), tuple(v[13:16]), tuple(v[16:19]), v[19]
    PALM = (-1.5, 2.0, -4.5)
    at = lambda sv: h.place(SHELL, AXIS, tuple(PORT[k] + PUSH[k] * sv for k in range(3)), PUSH)[0]
    pump = lambda f: h.place(PALM, (1, 0, 0), tuple(GRAB[k] + PULL[k] * TRAVEL * f for k in range(3)), (1, 0, 0))[0]
    load = ''
    for n in range(2):
        load += ('qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 10; qz_lhand "%s"; wait 12; qz_lhand "%s"; wait 12; qz_lhand "%s"; wait 15; qz_ltrigger 0; wait 10; ' % (FAR, at(-6), at(-2), at(DEPTH + 0.5)))
    s = ('wait 120; god; rsr_reload 1; rsr_grab_with 0; rsr_debug 1; ms_hand_pump 1; give %s; give %s 40; use %s; wait 100; +attack; wait 3; -attack; wait 50; +attack; wait 3; -attack; wait 50; +reload; wait 4; -reload; wait 25; ' % (cls, ammo, cls) + load +
         # THE HAND IS ON THE PUMP BEFORE THE SHOT (RS_ForeignReload.ShotWatch: at the mod's pump point the gun is held
         # only if the off hand is already on the pump -- grab held on it; a hand that is not there = the mod pumps)
         ('qz_lhand "%s"; wait 10; qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 10; +attack; wait 3; -attack; wait 25; qz_lhand "%s"; wait 12; qz_lhand "%s"; wait 12; qz_ltrigger 0; wait 40; quit' % (FAR, pump(0), pump(1.0), pump(0))))
    t = msmags.run('%s_pump_%s' % (tag, cls), files, s, 300)
    for l in t.splitlines():
        if re.search(r'^rsp t|B22 PS|Script error|VM abort|B22 SHOT', l): print(l[:170])
else:
    # 1) open it and dump the chambers; 2) load each chamber; flick shut with the gun hand
    s1 = ('wait 120; god; rsr_reload 1; rsr_debug 1; give %s; give %s 100; use %s; wait 100; +attack; wait 3; -attack; wait 30; +attack; wait 3; -attack; wait 40; +reload; wait 4; -reload; wait 40; quit' % (cls, ammo, cls))
    t = msmags.run('%s_open_%s' % (tag, cls), files, s1, 240)
    m = re.search(r'B22 BREAK gun (\d+) nch (\d+) theta \S+ hb (\S+) (\S+) (\S+) ht (\S+) (\S+) (\S+)', t)
    if not m: print('\n'.join(l for l in t.splitlines() if re.search(r'^rsb t|Script error|VM abort', l))[:2000]); sys.exit('break never OPENed')
    hb = np.array([float(x) for x in m.group(3, 4, 5)]); ht = np.array([float(x) for x in m.group(6, 7, 8)])
    ch = [(np.array([float(x) for x in a[0:3]]), np.array([float(x) for x in a[3:6]]), float(a[6])) for a in re.findall(r'B22 CH \d+ tip (\S+) (\S+) (\S+) bore (\S+) (\S+) (\S+) depth (\S+)', t)]
    seen = []; dd = []
    for tk, bk, dep in ch:
        key = tuple(np.round(tk, 2))
        if key in seen: continue
        seen.append(key); dd.append((tk, bk, dep))
    ch = dd
    gun_i = int(m.group(1))
    hinge = re.search(r'B22 HINGE gun %d axis (\S+) (\S+) (\S+)' % gun_i, t)
    roll_flick = hinge and abs(float(hinge.group(1))) > 0.5
    print('open: gun %s, %d chambers, hinge %s -> %s flick' % (m.group(1), len(ch), hinge.groups() if hinge else '?', 'ROLL' if roll_flick else 'PITCH'))
    load = ''
    for tk, bk, dep in ch:
        a = ht - hb
        load += ('qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 10; qz_lhand "%s"; wait 12; qz_lhand "%s"; wait 10; qz_lhand "%s"; wait 15; qz_ltrigger 0; wait 10; '
                 % (FAR, h.place(ht, a, tk - bk * (dep + 1.0), bk)[0], h.place(ht, a, tk - bk * (dep * 0.5), bk)[0], h.place(ht, a, tk, bk)[0]))
    RH = '0.25 1.3 -0.3 %s %s %s'
    s2 = ('wait 120; god; rsr_reload 1; rsr_debug 1; give %s; give %s 100; use %s; wait 100; +attack; wait 3; -attack; wait 30; +attack; wait 3; -attack; wait 40; +reload; wait 4; -reload; wait 30; %s qz_lhand "%s"; wait 10; qz_rhand "%s"; wait 4; qz_rhand "%s"; wait 40; quit'
          % (cls, ammo, cls, load, FAR, RH % (70, 0, 0), RH % (30, 0, 0)))
    t = msmags.run('%s_brk_%s' % (tag, cls), files, s2, 300)
    for l in t.splitlines():
        if re.search(r'^rsb t|B22 PS|Script error|VM abort|B22 SHOT', l): print(l[:170])
