import re, sys, math
# usage: python3 summ.py <rig log>... -- per run: parry decisions vs the real thrust-into-shot tics (from SPP_BLADE), tic order, hits, script errors

for name in sys.argv[1:]:
    L = open(name, errors="replace").read().splitlines()
    tips = {}; mon = None; pm = None
    for l in L:
        m = re.match(r"SPP_BLADE t(\d+) tip (\S+) (\S+) (\S+)", l)
        if m: tips[int(m.group(1))] = tuple(float(m.group(i)) for i in (2, 3, 4))
        m = re.match(r"SPP_MON \S+ at (\S+) (\S+) (\S+), .* player mid (\S+) (\S+) (\S+)", l)
        if m:
            v = [float(m.group(i)) for i in range(1, 7)]
            mon = v[:3]; pm = v[3:]
    if not mon:
        # probe-fired runs: the shot comes along the player-middle -> blade-middle line fixed at t40
        pm = [-96.0, 784.0, 84.0]
        for l in L:
            m = re.match(r"SPP_BLADE t(\d+) tip \S+ \S+ \S+ mid (\S+) (\S+) (\S+)", l)
            if m and int(m.group(1)) >= 40:
                mon = [float(m.group(i)) for i in (2, 3, 4)]; break
    hs = {"STOPPED": 0, "missed": 0}; order = {}
    par = {"PARRY": 0, "block": 0}; truepar = 0; truepar_counted = 0; truepar_list = []
    defl = {"DEFLECTED": 0, "pass": 0}; cont = {"RETURNED": 0, "hit": 0}
    hurt = 0; fires = 0; last = 0
    for l in L:
        m = re.match(r"SBX_HITSCAN t(\d+) (\S+) from \S+ -> (\S+)", l)
        if m: hs[m.group(3)] += 1; order[m.group(2)] = order.get(m.group(2), 0) + 1
        m = re.match(r"SBX_PARRY t(\d+) \S+ .* -> (\S+)", l)
        if m:
            t = int(m.group(1)); par[m.group(2)] += 1
            if t in tips and t - 1 in tips and mon:
                d = [tips[t][i] - tips[t - 1][i] for i in range(3)]
                sp = math.sqrt(sum(x * x for x in d))
                to = [mon[0] - pm[0], mon[1] - pm[1], 0]; tl = math.hypot(to[0], to[1])
                into = (d[0] * to[0] + d[1] * to[1]) / (sp * tl) if sp > 1e-3 else 0
                if sp >= 6 and into >= 0.3:
                    truepar += 1
                    if m.group(2) == "PARRY": truepar_counted += 1
                    truepar_list.append((t, round(sp, 1), m.group(2)))
        m = re.match(r"SBX_DEFLECT t\d+ \S+ (\S+) .* -> (\S+)", l)
        if m and "Blood" not in m.group(1): defl[m.group(2)] += 1
        m = re.match(r"SBX_CONTACT t\d+ \S+ \S+ -> (\S+)", l)
        if m: cont[m.group(1)] += 1
        if l.startswith("SPP_HURT"): hurt += 1
        if l.startswith("SPP_FIRE"): fires += 1
        m = re.match(r"SPP_BEAT t(\d+)", l)
        if m: last = int(m.group(1))
    errs = [l for l in L if "Script error" in l and "voxeldef" not in l]
    print(f"{name}: tics {last} probefires {fires} hitscan {hs} order {order} | parry decisions {par}, "
          f"real thrust-into-shot at that tic {truepar}, counted as parry {truepar_counted} | "
          f"deflect(non-blood) {defl} contact {cont} | player hit {hurt} | script errors {len(errs)}")
    if "-v" in sys.argv[0:1]: print(truepar_list)
