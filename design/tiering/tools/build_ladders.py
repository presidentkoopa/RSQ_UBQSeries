#!/usr/bin/env python3
"""PROPOSAL generator: per-family colour curves derived from ColorfulHell's own classes, and a 13-step
ladder for every BD22 and live XMVE monster. Reads data/*.json made by parse_ch.py, parse_dec.py,
spawner_sim.py. Writes data/family_curves.csv, data/bd_xmve_ladders.csv, data/bd_xmve_ladders.md."""
import json, math, statistics as st, csv
D = "/tmp/econ3/tiering/data"
ch = json.load(open(f"{D}/ch_ladder.json"))
TN = ['', 'Common', 'Green', 'Blue', 'Purple', 'Cyan', 'Brown', 'Yellow', 'FireBlu', 'Gray', 'Red', 'Abyss', 'Black', 'White']

def pav_up(v, minstep=1.05):
    """monotone non-decreasing fit (pool adjacent violators), then force a minimum step."""
    blocks = [[x, 1] for x in v]
    i = 0
    while i < len(blocks) - 1:
        if blocks[i][0] > blocks[i + 1][0]:
            a, b = blocks[i], blocks[i + 1]
            blocks[i:i + 2] = [[(a[0] * a[1] + b[0] * b[1]) / (a[1] + b[1]), a[1] + b[1]]]
            i = max(0, i - 1)
        else: i += 1
    out = []
    for val, n in blocks: out += [val] * n
    for k in range(1, len(out)):
        out[k] = max(out[k], out[k - 1] * minstep)
    return out

def pav_down(v, minstep=0.97):
    r = pav_up([1 / x if x else 1 for x in v], 1 / minstep)
    return [1 / x for x in r]

fams = {}
for r in ch['ladder']: fams.setdefault(r['family'], []).append(r)
curves = {}
for f, rs in fams.items():
    rs.sort(key=lambda r: r['tier'])
    b = rs[0]
    hp = [r['health'] / b['health'] for r in rs[:11]]
    sp = [r['speed'] / b['speed'] for r in rs[:11]]
    pc = [max(1, float(r['painchance'] or 1)) / max(1, float(b['painchance'] or 1)) for r in rs[:11]]
    H = pav_up(hp)
    S = [min(1.5, max(1.0, x)) for x in pav_up(sp, 1.0)]
    P = [min(1.0, x) for x in pav_down(pc, 1.0)]
    # world-tier boss grades (PROPOSAL B): continue the curve past Abyss
    H += [H[-1] * 1.25, H[-1] * 1.5]
    S += [min(1.6, S[-1] * 1.05), min(1.6, S[-1] * 1.1)]
    P += [P[-1] * 0.8, P[-1] * 0.6]
    bossH = [rs[11]['health'] / b['health'], rs[12]['health'] / b['health']]
    curves[f] = dict(rawhp=[r['health'] / b['health'] for r in rs], hp=H, speed=S, pain=P, boss=bossH)

# generic damage curve: CH median attack-volley ratio per colour, square-root damped (the rest of CH's damage
# growth is carried by the colour abilities), monotone. ESTIMATE.
vol = {t: [] for t in range(1, 14)}
for f, rs in fams.items():
    b = rs[0]
    if not b['volley']: continue
    for r in rs: vol[r['tier']].append(r['volley'] / b['volley'] if r['volley'] else 1.0)
med = [st.median(vol[t]) for t in range(1, 14)]
DMG = pav_up([math.sqrt(m) for m in med[:11]], 1.03)
DMG += [DMG[-1] * 1.15, DMG[-1] * 1.3]
DMG = [round(x, 2) for x in DMG]

with open(f"{D}/family_curves.csv", "w", newline='') as fh:
    w = csv.writer(fh)
    w.writerow(['family', 'row'] + TN[1:])
    for f, c in curves.items():
        w.writerow([f, 'CH raw HP x Common'] + [round(x, 2) for x in c['rawhp']])
        w.writerow([f, 'HP mult (proposal)'] + [round(x, 2) for x in c['hp']])
        w.writerow([f, 'speed mult'] + [round(x, 2) for x in c['speed']])
        w.writerow([f, 'painchance mult'] + [round(x, 2) for x in c['pain']])
    w.writerow(['ALL', 'damage mult (proposal)'] + DMG)
    w.writerow(['ALL', 'CH median volley x Common (est.)'] + [round(m, 2) for m in med])

# ------------------------------------------------------------------ BD22 + XMVE monsters
bd = {r['name'].lower(): r for r in json.load(open(f"{D}/bd22.json"))}
xm = {r['name'].lower(): r for r in json.load(open(f"{D}/xmve_live.json"))}
reach = json.load(open(f"{D}/xmve_reach.json"))
ALL = dict(bd); ALL.update({k: v for k, v in xm.items() if '/tmp/xmve' in v['file']})
BASE = {'riflezombie': 'Zombieman', 'shotgunguy1': 'Shotgunner', 'chaingunguy1': 'Chaingunner', 'imp': 'Imp',
        'bulldemon': 'Demon', 'spectro': 'Spectre', 'cacodemon_': 'Cacodemon', 'tehlostsoul': 'Lost Soul',
        'painelemental1': 'Pain Elemental', 'hellknight2': 'Hell Knight', 'baronofhell2': 'Baron',
        'revenant1': 'Revenant', 'mancubus': 'Mancubus', 'arachnotron1': 'Arachnotron', 'teharchvile': 'Arch-Vile',
        'thecyberdemon': 'Cyberdemon', 'thespidermastermind': 'Spider Mastermind'}
IDF = {'zombieman': 'Zombieman', 'shotgunguy': 'Shotgunner', 'chaingunguy': 'Chaingunner', 'doomimp': 'Imp',
       'demon': 'Demon', 'spectre': 'Spectre', 'cacodemon': 'Cacodemon', 'lostsoul': 'Lost Soul',
       'painelemental': 'Pain Elemental', 'hellknight': 'Hell Knight', 'baronofhell': 'Baron', 'revenant': 'Revenant',
       'fatso': 'Mancubus', 'arachnotron': 'Arachnotron', 'archvile': 'Arch-Vile', 'cyberdemon': 'Cyberdemon',
       'spidermastermind': 'Spider Mastermind', 'wolfensteinss': 'Zombieman'}
# monsters with no Doom ancestor: the slot XMVE's spawner puts them in, or their summoner (by reading the code)
ORPHAN = {'aracnorb': 'Cacodemon', 'aracnorbqueenboss': 'Spider Mastermind', 'aracnorbqueenbossboss': 'Spider Mastermind',
          'blooddemon': 'Demon', 'bloodspectre': 'Spectre', 'impureelemental': 'Cacodemon', 'stealthimpureelemental': 'Cacodemon',
          'terminatordemon': 'Baron', 'terminatorboss': 'Baron', 'helmetriflezombie': 'Zombieman', 'paingasm': 'Pain Elemental',
          'evilmarinerifle': 'Chaingunner', 'easymarinerifle': 'Chaingunner', 'ubersoldat': 'Chaingunner',
          'aracnorbqueen': 'Cacodemon', 'brutalnightmaredemon': 'Demon', 'brutalannihilator': 'Cyberdemon',
          'cacoasshole': 'Cacodemon', 'afrit': 'Baron', 'alphalostsoul': 'Lost Soul', 'invisiblealien': 'Spectre',
          'ancientflyingcunt': 'Lost Soul', 'u_archangelusa': 'Cyberdemon', 'u_archangelusb': 'Cyberdemon',
          'ziobrutalwolfensteinss': 'Zombieman', 'motherdemon': 'Spider Mastermind', 'bdmummy': 'Zombieman',
          'grell': 'Cacodemon'}
EXEMPT = {'titan': 'scripted Icon/Titan fight', 'minititan': 'scripted', 'iconofsin': 'scripted Icon of Sin',
          'gatekeeper': 'scripted', 'bossbrainreplacer': 'Icon of Sin brain', 'demonwitch': 'boss-brain stand-in',
          'bosseyechecker': 'boss eye', 'd64d2bosseye': 'boss eye', 'commander_keen': 'hanging Keen (map trigger)',
          'dopefish': 'joke actor', 'tntrevilutionditeamfortress2': 'map prop', 'tntrevilutionditeamfortress2_2': 'map prop'}
# a heavier attack than the family base, read from code: damage ratio vs the base's main shot
DMGR = {'superimp': (2.5, 'A_BruisAttack -> BD GreenPlasmaBall Damage (50) vs Imp FireBall_ (20): Imps.dec:1418, Knight.dec:654, SuperImp.txt:17')}
FAMBASEHP = {BASE[k]: bd[k]['health'] for k in BASE}

def family_of(name, depth=0):
    k = name.lower()
    if k in BASE: return BASE[k]
    if k in ORPHAN: return ORPHAN[k]
    if k in IDF: return IDF[k]
    a = ALL.get(k)
    if not a or depth > 12: return None
    if a.get('replaces') and a['replaces'].lower() in IDF and k not in ('riflezombie',):
        pass
    if a['parent']:
        f = family_of(a['parent'], depth + 1)
        if f: return f
    if a.get('replaces') and a['replaces'].lower() in IDF: return IDF[a['replaces'].lower()]
    return None

def entry(f, T, isboss):
    H = curves[f]['hp']
    n0 = 1
    for t in range(1, 12):
        if H[t - 1] <= T * 1.02: n0 = t
    if T > H[10] * 1.3: n0 = 12 if T < H[10] * 1.5 * 1.3 else 13
    return n0

rows = []
skip_words = ('cast', 'checker', 'surrendered', 'deadlostsoulspawner', 'friendly', 'helmetsergeantlaststand2', 'marineeattenbydemon')
for k, r in ALL.items():
    if not r['monster'] or not r['countkill'] or '+FRIENDLY' in r['flags']: continue
    if any(s in k for s in skip_words): continue
    src = 'XMVE' if '/tmp/xmve' in r['file'] else 'BD22'
    if src == 'BD22' and ('/Enemies/' not in r['file'] or 'Arachnorb.dec' in r['file']): continue
    hp = r['health']
    if hp is None: continue
    loc = r['file'].replace('/tmp/bd22src/', 'bd22:').replace('/tmp/', '') + f":{r['line']}"
    how = '; '.join(reach.get(k, [])) if src == 'XMVE' else ''
    if k in EXEMPT:
        rows.append(dict(name=r['name'], src=src, loc=loc, hp=hp, fam='-', n0='exempt', why=EXEMPT[k], ladder=[], how=how)); continue
    f = family_of(r['name'])
    if not f:
        rows.append(dict(name=r['name'], src=src, loc=loc, hp=hp, fam='?', n0='?', why='no Doom family found', ladder=[], how=how)); continue
    ratio = hp / FAMBASEHP[f]
    dm, dwhy = DMGR.get(k, (1.0, ''))
    T = ratio * math.sqrt(dm) if dm != 1.0 else ratio
    n0 = entry(f, T, '+BOSS' in r['flags'])
    H = curves[f]['hp']
    lad = []
    for t in range(1, 14):
        lad.append('' if t < n0 else int(round(hp * H[t - 1] / H[n0 - 1])))
    why = f"HP {hp:g} = {ratio:.2f}x {f} base {FAMBASEHP[f]:g}" + (f"; damage x{dm} ({dwhy})" if dwhy else '')
    if '+BOSS' in r['flags']: why += '; +BOSS'
    rows.append(dict(name=r['name'], src=src, loc=loc, hp=hp, fam=f, n0=n0, why=why, ladder=lad, how=how))
rows.sort(key=lambda x: (x['src'], x['fam'], x['hp']))
with open(f"{D}/bd_xmve_ladders.csv", "w", newline='') as fh:
    w = csv.writer(fh)
    w.writerow(['source', 'class', 'file:line', 'base HP', 'family', 'entry tier', 'why', 'how it appears'] + [f"HP@{t}" for t in TN[1:]])
    for x in rows:
        w.writerow([x['src'], x['name'], x['loc'], x['hp'], x['fam'], x['n0'], x['why'], x['how']] + list(x['ladder']))
with open(f"{D}/bd_xmve_ladders.md", "w") as fh:
    fh.write("| src | class | HP | family | entry | " + " | ".join(t[:3] for t in TN[1:]) + " |\n|" + "---|" * 18 + "\n")
    for x in rows:
        e = x['n0'] if isinstance(x['n0'], str) else f"{x['n0']} {TN[x['n0']]}"
        fh.write(f"| {x['src']} | {x['name']} | {x['hp']:g} | {x['fam']} | {e} | " + " | ".join(str(v) for v in (x['ladder'] or [''] * 13)) + " |\n")
print("damage curve:", DMG)
for f, c in curves.items():
    print(f"{f:18} HP " + ' '.join(f"{x:5.2f}" for x in c['hp']) + " | spd " + ' '.join(f"{x:.2f}" for x in c['speed']) + " | pain " + ' '.join(f"{x:.2f}" for x in c['pain']))
print(len(rows), "monster rows")
