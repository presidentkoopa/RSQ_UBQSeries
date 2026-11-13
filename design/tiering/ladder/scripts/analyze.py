# Driver: simulate every ladder class (17 families x 13 colours + EX) and their summons. Research only.
import sys, json, re, pickle, math, os, time
sys.path.insert(0, '/tmp/econ3/ladder/scripts')
import sim
from multiprocessing import Pool

sim.load('/tmp/econ3/ladder/scripts/rsq_classes.pkl')
OUT = '/tmp/econ3/ladder/scripts/simres.pkl'
LD = json.load(open('/tmp/rscripts/ladder.json'))
FAMS = {0: 'Chaingunner', 1: 'Revenant', 2: 'Mancubus', 3: 'Arch-Vile', 4: 'Baron', 5: 'Lost Soul', 6: 'Pain Elemental',
        7: 'Cyberdemon', 8: 'Mastermind', 9: 'Demon', 10: 'Cacodemon', 11: 'Hell Knight', 12: 'Arachnotron', 13: 'Imp',
        14: 'Shotgunner', 15: 'Spectre', 16: 'Zombieman'}
COLS = ['Common', 'Green', 'Blue', 'Purple', 'Cyan', 'Brown', 'Yellow', 'FireBlu', 'Gray', 'Red', 'Abyss', 'Black', 'White']
EX = {'RS_BlackZombieEX': (16, 12), 'RS_BlackCGuyEX': (0, 12), 'RS_BlackImpEX': (13, 12), 'RS_BlackCacoEX': (10, 12),
      'RS_BlackHKEX': (11, 12), 'RS_BlackRevenantEX': (1, 12), 'RS_BlackFatsoEX': (2, 12), 'RS_BlackSPEX': (12, 12),
      'RS_WhiteSGEX': (14, 13), 'RS_WhiteLSoulEX': (5, 13)}
RANGES = (256, 512, 40)

def one(n):
    out = {}
    for d in RANGES:
        r = sim.simulate(n, d, runs=int(os.environ.get('RUNS', '24')))
        T = r.t / 35.0
        out[d] = {'dps': r.dmg / T, 'att_s': r.attacks / T, 'chase_frac': r.chase_t / max(1, r.t),
                  'speed_mean': (r.speed_t / r.chase_t * 1.0) if r.chase_t else 0,
                  'summ_per_s': {k: v / T for k, v in r.summ.items()}, 'heal_others_s': r.heal_others / T,
                  'heal_self_s': r.heal_self / T, 'invul_frac': r.invul_t / max(1, r.t), 'refl_frac': r.refl_t / max(1, r.t),
                  'teleports_s': r.teleports / T, 'hops_s': r.hops / T, 'charges_s': r.charges / T, 'raises_s': r.raises / T,
                  'selfkill_s': r.selfkill / T, 'by': {k: v / T for k, v in r.dmg_by.items()}, 'tags': sorted(r.tags)}
    return n, out

def main():
    names = []
    for k, (c, ln) in LD['cls'].items(): names.append(c)
    names += list(EX)
    names = sorted(set(names))
    done = {}
    if os.path.exists(OUT): done = pickle.load(open(OUT, 'rb'))
    todo = [n for n in names if n not in done]
    t0 = time.time()
    with Pool(2) as p:
        for i, (n, o) in enumerate(p.imap_unordered(one, todo)):
            done[n] = o
            if i % 10 == 0:
                pickle.dump(done, open(OUT, 'wb')); print(i, len(todo), n, round(time.time() - t0), flush=True)
    pickle.dump(done, open(OUT, 'wb'))
    # summons, second pass (expand spawners)
    summ = set()
    for n, o in done.items():
        for d in (256, 512):
            for s in o[d]['summ_per_s']: summ.add(s)
    exp = set()
    for s in summ:
        if sim.is_spawner(s):
            for k in sim.spawner_expand(s): exp.add(k)
        else: exp.add(s)
    todo = [s for s in exp if s not in done and sim.cls(s)]
    print('summons to sim', len(todo), todo[:40], flush=True)
    with Pool(2) as p:
        for i, (n, o) in enumerate(p.imap_unordered(one, todo)):
            done[n] = o
    pickle.dump(done, open(OUT, 'wb'))
    print('done', round(time.time() - t0))

if __name__ == '__main__':
    main()
