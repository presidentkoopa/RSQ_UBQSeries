# Place BD22 and XMVE monsters on the ColorfulHell ladder. Research only.
import sys, json, pickle, math, statistics as st
sys.path.insert(0, '/tmp/econ3/ladder/scripts')
SET = sys.argv[1]
import build, sim
if SET == 'bd22':
    sim.load('/tmp/econ3/ladder/scripts/bd22_classes.pkl')
else:
    sim.load('/tmp/econ3/ladder/scripts/bd22_classes.pkl', '/tmp/econ3/ladder/scripts/xmve_classes.pkl')
sim.PI.clear(); sim.MA.clear(); sim.SPM.clear(); build.REPL.clear()
RB = pickle.load(open(f'/tmp/econ3/ladder/scripts/simres_{SET}.pkl', 'rb'))
build.R = dict(build.R); build.R.update({k: v for k, v in RB.items() if 'error' not in v})
COLS = build.COLS
T = json.load(open('/tmp/econ3/ladder/tiers.json'))['rows']
FAMROWS = {}
for r in T:
    if not r['colour'].endswith('EX'): FAMROWS.setdefault(r['family'], []).append(r)

# family each monster ACTS like (behaviour first; spawn slot second) -- judgement, reasons in the report
ACTS = {
 'RifleZombie': 'Zombieman', 'PistolZombie': 'Zombieman', 'Labguy': 'Zombieman', 'LabGuy': 'Zombieman', 'LabGAL': 'Zombieman',
 'LabGuyB': 'Zombieman', 'LabGuyP': 'Zombieman', 'SniperRifleGuy': 'Zombieman', 'PlasmaZombie': 'Chaingunner',
 'ChainsawZombie': 'Demon', 'MinigunGuy': 'Chaingunner', 'BDMummy': 'Demon',
 'ShotgunGuy1': 'Shotgunner', 'SMGGuy': 'Chaingunner', 'RiotShieldGuy': 'Shotgunner', 'SuperShotgunZombie': 'Shotgunner',
 'ASGGuy': 'Shotgunner', 'PyroSergeant': 'Shotgunner', 'RocketGuy': 'Imp', 'QuadShotgunZombie': 'Shotgunner',
 'EvilMarine': 'Chaingunner', 'EvilMarineLasgun': 'Chaingunner',
 'ChaingunGuy1': 'Chaingunner', 'Major': 'Chaingunner', 'RifleCommando': 'Chaingunner', 'ZSpecOps': 'Chaingunner',
 'ZSpecOpsRail': 'Chaingunner', 'ZSpecOpsRifle': 'Chaingunner', 'XVStealthZSpecOps': 'Chaingunner', 'HellTrooper': 'Chaingunner',
 'Imp': 'Imp', 'Imp3': 'Imp', 'SuperImp': 'Imp', 'NetherDarkImp': 'Imp', 'VoidDarkImp': 'Imp', 'NamiDarkImp': 'Imp', 'DarkImp': 'Imp',
 'BullDemon': 'Demon', 'FatPinky': 'Demon', 'BloodDemon': 'Demon', 'Spectro': 'Spectre', 'VoidSpectre': 'Spectre',
 'Cacodemon_': 'Cacodemon', 'Overlord': 'Cacodemon', 'ImpureElemental': 'Pain Elemental', 'AracnorbQueen': 'Cacodemon',
 'TehLostSoul': 'Lost Soul', 'PainElemental1': 'Pain Elemental', 'SufferingElemental': 'Pain Elemental',
 'HellKnight2': 'Hell Knight', 'CyberKnight': 'Hell Knight',
 'BaronofHell2': 'Baron', 'BaronBoss1': 'Baron', 'CyberBaron': 'Baron', 'BruiserDemon': 'Baron', 'PyroDemon': 'Baron',
 'TerminatorDemon': 'Baron',
 'Revenant1': 'Revenant', 'Draugr': 'Revenant', 'Incarnate': 'Revenant',
 'Mancubus': 'Mancubus', 'Volcabus': 'Mancubus', 'Daedabus': 'Mancubus',
 'Arachnotron1': 'Arachnotron', 'Arachnotron2': 'Arachnotron', 'AASpider': 'Arachnotron', 'CGSpider': 'Arachnotron',
 'Minimastermind': 'Arachnotron', 'Minimastermindx': 'Arachnotron',
 'TehArchvile': 'Arch-Vile', 'Diabloist': 'Arch-Vile',
 'TheCyberdemon': 'Cyberdemon', 'Annihilator': 'Cyberdemon', 'SuperDemon': 'Cyberdemon', 'Thamuz': 'Cyberdemon',
 'TheSpiderMastermind': 'Mastermind', 'SpidermastermindX': 'Mastermind', 'AracnorbQueenBOSS': 'Mastermind',
}

def place(val, fam, key):
    """where val sits among the family's 13 colours by key: bracketing colours in sorted order + fractional tier on the
    family's monotone (isotonic, by owner order) curve"""
    rows = sorted(FAMROWS[fam], key=lambda r: r['tier'])
    xs = [key(r) for r in rows]
    srt = sorted(zip(xs, [r['colour'] for r in rows]))
    lo = [c for v, c in srt if v <= val]; hi = [c for v, c in srt if v > val]
    below = (lo[-1], [v for v, c in srt if c == lo[-1]][0]) if lo else None
    above = (hi[0], [v for v, c in srt if c == hi[0]][0]) if hi else None
    # isotonic (pool-adjacent-violators) on log values in owner order -> fractional tier
    ys = [math.log(max(x, 1e-3)) for x in xs]
    blocks = [[y, 1] for y in ys]
    i = 0
    while i < len(blocks) - 1:
        if blocks[i][0] > blocks[i + 1][0]:
            a, b = blocks[i], blocks[i + 1]
            blocks[i] = [(a[0] * a[1] + b[0] * b[1]) / (a[1] + b[1]), a[1] + b[1]]; del blocks[i + 1]; i = max(0, i - 1)
        else: i += 1
    iso = []
    for v, n in blocks: iso += [v] * n
    lv = math.log(max(val, 1e-3))
    if lv <= iso[0]: ft = 1.0
    elif lv >= iso[-1]: ft = 13.0
    else:
        ft = None
        for k in range(12):
            if iso[k] <= lv <= iso[k + 1]:
                ft = k + 1 + ((lv - iso[k]) / (iso[k + 1] - iso[k]) if iso[k + 1] > iso[k] else 0); break
        # flat stretch: first tier reaching the value
        if ft is None: ft = 13.0
    return {'below': below, 'above': above, 'fractional_tier': round(ft, 2), 'iso_colour': COLS[min(12, int(round(ft)) - 1)]}

def nearest(ci, fam):
    rows = FAMROWS[fam]
    b = min(rows, key=lambda x: abs(math.log(max(x['challenge_index'], 1e-3)) - math.log(max(ci, 1e-3))))
    return {'colour': b['colour'], 'ci': b['challenge_index'], 'family_common_ci': [x for x in rows if x['tier'] == 1][0]['challenge_index']}

def main():
    out = []
    imp = [r for r in T if r['class'] == 'RS_CommonImp'][0]
    vref = imp['mobility']['ground_speed_u_per_tic']
    refraw = None
    for n in sorted(RB):
        if 'error' in RB[n]: out.append({'class': n, 'error': RB[n]['error']}); continue
        fam = ACTS.get(n)
        if not fam: continue
        r = build.build_row(n, 0, 0, '-')
        r['family'] = fam; r['set'] = SET
        dps = (r['dps_256'] + r['dps_512']) / 2
        raw = math.sqrt(max(r['ehp'], 1) * max(dps, 0.1)) * build.mobility_mult(r['mobility'], vref)
        rawimp = math.sqrt(imp['ehp'] * (imp['dps_256'] + imp['dps_512']) / 2) * build.mobility_mult(imp['mobility'], vref)
        r['challenge_index'] = round(raw / rawimp, 2)
        r['place_by_ci'] = place(r['challenge_index'], fam, lambda x: x['challenge_index'])
        r['place_by_hp'] = place(r['hp'], fam, lambda x: x['hp'])
        r['place_by_dps'] = place(max(dps, 0.01), fam, lambda x: (x['dps_256'] + x['dps_512']) / 2)
        for k in ('tier', 'colour'): r.pop(k, None)
        out.append(r)
    json.dump(out, open(f'/tmp/econ3/ladder/{SET}_on_ladder.json', 'w'), indent=1)
    for r in out:
        if 'error' in r: print(r['class'], 'ERR', r['error'][:80]); continue
        pc, ph, pd = r['place_by_ci'], r['place_by_hp'], r['place_by_dps']
        r['nearest_colour_by_ci'] = nearest(r['challenge_index'], r['family'])
        print(f"{r['class']:20} {r['family']:14} HP={r['hp']:6.0f} spd={r['speed']['speed']:4.0f} DPS={r['dps_256']:6.1f}/{r['dps_512']:6.1f} CI={r['challenge_index']:6.2f} "
              f"| nearestCI={r['nearest_colour_by_ci']['colour']}({r['nearest_colour_by_ci']['ci']}) between {pc['below'][0] if pc['below'] else '-'}..{pc['above'][0] if pc['above'] else '-'} "
              f"| HP~{ph['fractional_tier']:5.2f} DPS~{pd['fractional_tier']:5.2f} | {sorted(r['threat_abilities'])[:4]}")

if __name__ == '__main__':
    main()
