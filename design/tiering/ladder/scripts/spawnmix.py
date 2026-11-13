# Exact colour distribution of a ColorfulHell spawn today, from the dials and the gate classes. Research only.
import sys, json, re
sys.path.insert(0, '/tmp/econ3/ladder/scripts')
import sim
sim.load('/tmp/econ3/ladder/scripts/rsq_classes.pkl')
LD = json.load(open('/tmp/rscripts/ladder.json'))
COLS = ['Common', 'Green', 'Blue', 'Purple', 'Cyan', 'Brown', 'Yellow', 'FireBlu', 'Gray', 'Red', 'Abyss', 'Black', 'White']
FAMS = {0: 'Chaingunner', 1: 'Revenant', 2: 'Mancubus', 3: 'Arch-Vile', 4: 'Baron', 5: 'Lost Soul', 6: 'Pain Elemental',
        7: 'Cyberdemon', 8: 'Mastermind', 9: 'Demon', 10: 'Cacodemon', 11: 'Hell Knight', 12: 'Arachnotron', 13: 'Imp',
        14: 'Shotgunner', 15: 'Spectre', 16: 'Zombieman'}
# class -> (fam, tier) from the ladder tables (ClassFor) and EX names
CT = {}
for k, (c, ln) in LD['cls'].items():
    f, t = map(int, k.split(',')); CT.setdefault(c.lower(), (f, t))
for c in ['RS_BlackZombieEX', 'RS_BlackCGuyEX', 'RS_BlackImpEX', 'RS_BlackCacoEX', 'RS_BlackHKEX', 'RS_BlackRevenantEX',
          'RS_BlackFatsoEX', 'RS_BlackSPEX']:
    CT[c.lower()] = (None, 'EX12')
CT['rs_whitesgex'] = (14, 'EX13'); CT['rs_whitelsoulex'] = (5, 'EX13')

GATES = set(v[0].lower() for v in LD['gate'].values()) - set(v[0].lower() for v in LD['cls'].values())
def name_tier(n):   # RS_Roster.zs:219 TierOf (name-derived)
    s = n.lower()
    for w, t in (('fireblu', 8), ('common', 1), ('green', 2), ('blue', 3), ('purple', 4), ('cyan', 5), ('brown', 6),
                 ('yellow', 7), ('gray', 9), ('red', 10), ('abyss', 11), ('black', 12), ('white', 13)):
        if w in s: return t
    return 1

def dial_entries(dial):
    c = sim.cls(dial)
    return [(nm, w) for nm, p, w, ln in c['dropitems'] if nm.lower() != 'none']

def gate_outcomes(n, cv, depth=0):
    """walk a gate/stub class from Spawn; returns {spawned_class: prob}; a class that is a real monster returns itself"""
    c = sim.cls(n)
    if c is None: return {'?' + n: 1.0}
    if (sim.is_monster(n) and n.lower() not in GATES) or sim.is_spawner(n): return {n: 1.0}
    out = {}
    def walk(pos, p, steps=0):
        if p <= 1e-12 or pos is None or steps > 200: return
        cn, idx = pos
        f = sim.cls(cn)['frames'][idx]
        for fn, a in sim.calls(f.get('act', '')):
            fl = fn.lower()
            if fl == 'a_jumpif':
                m = re.search(r"RS_Zom\.CV\(\s*'(\w+)'\s*,\s*(-?\d+)\s*\)\s*==\s*(-?\d+)", a[0])
                if m:
                    val = cv.get(m.group(1), int(m.group(2)))
                    if val == int(m.group(3)):
                        walk(sim.resolve_label(n, sim.sarg(a, 1)), p, steps + 1); return
                    continue
            if fl == 'a_jump':
                ch = float(sim.sarg(a, 0, '0')); q = min(1.0, ch / 256.0)
                labs = a[1:]
                for lb in labs: walk(sim.resolve_label(n, lb.strip('"')), p * q / len(labs), steps + 1)
                p = p * (1 - q)
                if p <= 0: return
                continue
            if fl == 'a_spawnitemex':
                tgt = sim.sarg(a, 0); out[tgt] = out.get(tgt, 0) + p; return
        walk(sim.static_goto(cn, idx), p, steps + 1)
    walk(sim.resolve_label(n, 'spawn'), 1.0)
    return out

def final_dist(fam, cv, cap=13):
    """distribution over final classes for one spawn of family fam (ladder index), given cvars and roster cap"""
    dial = LD['dial'][str(fam)]
    ents = dial_entries(dial)
    if cap < 13:
        pick = [(nm, w) for nm, w in ents if name_tier(nm) <= cap]   # RS_Roster.zs:256
    else:
        pick = ents
    tot = sum(w for nm, w in pick)
    full_tot = sum(w for nm, w in ents)
    # resolve each entry to final classes; 'dial' references = full uncapped re-roll (RS_ImpColourset spawned by a gate)
    def resolve(nm, depth=0):
        if depth > 8: return {}, 0.0
        if nm.lower() == dial.lower(): return {}, 1.0
        oc = gate_outcomes(nm, cv)
        res = {}; back = 0.0
        for k, p in oc.items():
            if k.lower() == dial.lower(): back += p; continue
            if k.lower() in CT or sim.is_monster(k):
                if k.lower() in CT or not sim.cls(k) or True:
                    # a spawned class could itself be a gate (white gate -> black gate)
                    if sim.is_monster(k) and k.lower() not in GATES:
                        res[k] = res.get(k, 0) + p; continue
            r2, b2 = resolve(k, depth + 1)
            for kk, pp in r2.items(): res[kk] = res.get(kk, 0) + p * pp
            back += p * b2
        return res, back
    cache = {nm: resolve(nm) for nm, w in ents}
    # full dial: D = sum w_i/W (res_i + back_i * D)  ->  D = A / (1 - r)
    A = {}; r = 0.0
    for nm, w in ents:
        res, b = cache[nm]
        for k, p in res.items(): A[k] = A.get(k, 0) + w / full_tot * p
        r += w / full_tot * b
    D = {k: v / (1 - r) for k, v in A.items()}
    if cap >= 13: return D, r
    # capped pick: P = sum w_i/T (res_i + back_i * D)   (the re-roll escapes the cap)
    P = {}; leak = 0.0
    for nm, w in pick:
        res, b = cache[nm]
        for k, p in res.items(): P[k] = P.get(k, 0) + w / tot * p
        for k, p in D.items(): P[k] = P.get(k, 0) + w / tot * b * p
        leak += w / tot * b
    return P, leak

def tier_of_class(k):
    t = CT.get(k.lower())
    if t: return t[1]
    return name_tier(k)

if __name__ == '__main__':
    import itertools
    cvs = {'default (extras off, bosses on, EX 24/256)': dict(sim.CV_DEFAULTS),
           'all extras on (2)': dict(sim.CV_DEFAULTS, rs_ch_brown=2, rs_ch_cyan=2, rs_ch_fireblu=2, rs_ch_gray=2, rs_ch_abyss=2)}
    out = {}
    for lab, cv in cvs.items():
        out[lab] = {}
        for fam in range(17):
            D, r = final_dist(fam, cv)
            bt = {}
            for k, p in D.items():
                t = tier_of_class(k); bt[str(t)] = bt.get(str(t), 0) + p
            out[lab][FAMS[fam]] = {'by_tier': bt, 'reroll_mass': r, 'classes': D}
    json.dump(out, open('/tmp/econ3/ladder/spawn_today.json', 'w'), indent=1)
    for lab in out:
        print('==', lab)
        for fam, v in out[lab].items():
            bt = v['by_tier']
            print(f"{fam:15} reroll={v['reroll_mass']:.3f} " + ' '.join(f"{COLS[int(t)-1] if t.isdigit() else t}:{p*100:.2f}" for t, p in sorted(bt.items(), key=lambda x: (len(x[0]), x[0]))))
