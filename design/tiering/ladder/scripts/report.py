# Ladder statistics from tiers.json: per-tier medians, ordering check, colour abilities. Research only.
import json, statistics as st, math, sys
COLS = ['Common', 'Green', 'Blue', 'Purple', 'Cyan', 'Brown', 'Yellow', 'FireBlu', 'Gray', 'Red', 'Abyss', 'Black', 'White']
D = json.load(open('/tmp/econ3/ladder/tiers.json'))['rows']
base = [r for r in D if not r['colour'].endswith('EX')]
ex = [r for r in D if r['colour'].endswith('EX')]
fams = sorted(set(r['family'] for r in D))
def by(f): return sorted([r for r in base if r['family'] == f], key=lambda r: r['tier'])

def spearman(xs):
    n = len(xs); rk = {v: i for i, v in enumerate(sorted(range(n), key=lambda i: xs[i]))}
    d2 = sum((rk[i] - i) ** 2 for i in range(n)); return 1 - 6 * d2 / (n * (n * n - 1))

def inversions(xs):
    return sum(1 for i in range(len(xs)) for j in range(i + 1, len(xs)) if xs[j] < xs[i])

out = {'per_tier': [], 'ordering': {}, 'variants': {}, 'colour_abilities': {}, 'ci_order_per_family': {}, 'ex': []}
print('## per-tier medians across 17 families')
for t in range(1, 14):
    rs = [r for r in base if r['tier'] == t]
    ci = [r['challenge_index'] for r in rs]; hp = [r['hp'] for r in rs]; e = [r['ehp'] for r in rs]
    dp = [(r['dps_256'] + r['dps_512']) / 2 for r in rs]
    row = {'tier': t, 'colour': COLS[t - 1], 'ci_median': round(st.median(ci), 2), 'ci_min': min(ci), 'ci_max': max(ci),
           'ci_min_family': min(rs, key=lambda r: r['challenge_index'])['family'],
           'ci_max_family': max(rs, key=lambda r: r['challenge_index'])['family'],
           'hp_median': st.median(hp), 'ehp_median': st.median(e), 'dps_median': round(st.median(dp), 1),
           'dps256_median': round(st.median([r['dps_256'] for r in rs]), 1), 'dps512_median': round(st.median([r['dps_512'] for r in rs]), 1),
           'ci_geomean': round(math.exp(sum(math.log(max(c, 0.01)) for c in ci) / len(ci)), 2),
           'ci_rel_common_median': round(st.median([r['challenge_index'] / by(r['family'])[0]['challenge_index'] for r in rs]), 2),
           'hp_rel_common_median': round(st.median([r['hp'] / by(r['family'])[0]['hp'] for r in rs]), 2),
           'dps_rel_common_median': round(st.median([((r['dps_256'] + r['dps_512']) / 2) / max(0.5, (by(r['family'])[0]['dps_256'] + by(r['family'])[0]['dps_512']) / 2) for r in rs]), 2),
           'speed_rel_common_median': round(st.median([r['mobility']['ground_speed_u_per_tic'] / max(0.3, by(r['family'])[0]['mobility']['ground_speed_u_per_tic']) for r in rs]), 2)}
    out['per_tier'].append(row)
    print(f"{t:2} {COLS[t-1]:8} CI med={row['ci_median']:7.2f} rel={row['ci_rel_common_median']:5.2f} [{row['ci_min']:.2f} {row['ci_min_family']} .. {row['ci_max']:.2f} {row['ci_max_family']}]  HPrel={row['hp_rel_common_median']:5.2f} DPSrel={row['dps_rel_common_median']:5.2f} SPDrel={row['speed_rel_common_median']:4.2f} EHPmed={row['ehp_median']:.0f} DPSmed={row['dps_median']}")
for r in ex:
    out['ex'].append({'family': r['family'], 'class': r['class'], 'ci': r['challenge_index'], 'hp': r['hp'],
                      'black_ci': by(r['family'])[11]['challenge_index'], 'white_ci': by(r['family'])[12]['challenge_index']})
print('## EX'); [print(x) for x in out['ex']]

print('## ordering per family (CI vs owner order)')
def check(key):
    res = {}
    for f in fams:
        xs = [key(r) for r in by(f)]
        res[f] = {'spearman': round(spearman(xs), 3), 'inversions_of_78': inversions(xs)}
    return res
variants = {
    'CI (sqrt(EHP*DPS) x mobility)': lambda r: r['challenge_index'],
    'HP only': lambda r: r['hp'],
    'EHP only': lambda r: r['ehp'],
    'DPS only (mean 256/512)': lambda r: r['dps_256'] + r['dps_512'],
    'EHP x DPS without mobility': lambda r: r['ehp'] * (r['dps_256'] + r['dps_512']),
    'CI at 256 only': lambda r: math.sqrt(r['ehp'] * max(r['dps_256'], .1)),
    'CI at 512 only': lambda r: math.sqrt(r['ehp'] * max(r['dps_512'], .1)),
}
for nm, fn in variants.items():
    res = check(fn)
    out['variants'][nm] = {'median_spearman': st.median(v['spearman'] for v in res.values()),
                           'total_inversions': sum(v['inversions_of_78'] for v in res.values()),
                           'per_family': res}
    print(f"{nm:34} median rho={out['variants'][nm]['median_spearman']:.3f} inversions={out['variants'][nm]['total_inversions']} of {78*17}")
# per-tier median monotonic?
med = [x['ci_median'] for x in out['per_tier']]
out['median_monotonic_breaks'] = [(COLS[i], COLS[i + 1], med[i], med[i + 1]) for i in range(12) if med[i + 1] < med[i]]
print('median breaks', out['median_monotonic_breaks'])
for f in fams:
    rs = by(f); xs = [r['challenge_index'] for r in rs]
    breaks = []
    for i in range(1, 13):
        prevmax = max(xs[:i]); k = xs[:i].index(prevmax)
        if xs[i] < prevmax * 0.8:
            breaks.append({'colour': COLS[i], 'ci': xs[i], 'below': COLS[k], 'below_ci': prevmax,
                           'hp': rs[i]['hp'], 'dps': round((rs[i]['dps_256'] + rs[i]['dps_512']) / 2, 1)})
    out['ordering'][f] = {'ci': dict(zip(COLS, xs)), 'spearman': round(spearman(xs), 3), 'breaks': breaks}
    order = sorted(range(13), key=lambda i: xs[i])
    out['ci_order_per_family'][f] = [COLS[i] for i in order]
    exr = [r for r in ex if r['family'] == f]
    print(f"{f:15} rho={spearman(xs):.2f} CI-order: {' < '.join(COLS[i] for i in order)}" + (f"  | EX CI {exr[0]['challenge_index']}" if exr else ''))
# colour abilities: which abilities show up per colour (count families)
for t in range(1, 14):
    rs = [r for r in base if r['tier'] == t]
    cnt = {}
    for r in rs:
        keys = set()
        for a in list(r['threat_abilities']) + r['sim_tags']:
            k = a.split(' (')[0].split(' via')[0]
            keys.add(k)
        for k in keys: cnt[k] = cnt.get(k, 0) + 1
    out['colour_abilities'][COLS[t - 1]] = dict(sorted(cnt.items(), key=lambda x: -x[1]))
    print(COLS[t - 1], {k: v for k, v in sorted(cnt.items(), key=lambda x: -x[1]) if v >= 3})
json.dump(out, open('/tmp/econ3/ladder/ladder_stats.json', 'w'), indent=1)
