# "+1 tier per gun turn-in": spawn-mix options over the 13 colours + EX. Research only.
import json, math, sys
sys.path.insert(0, '/tmp/econ3/ladder/scripts')
from spawnmix import final_dist, tier_of_class, FAMS, COLS
import sim
EXFAM = {16: 12, 0: 12, 13: 12, 10: 12, 11: 12, 1: 12, 2: 12, 12: 12, 14: 13, 5: 13}   # family -> colour whose gate rolls EX
EXP = 24 / 256.0   # rs_ch_exboss 1 (RS_Imp.zs:160-162: A_Jump(232,"EX1No"))
ALL_ON = dict(sim.CV_DEFAULTS, rs_ch_brown=2, rs_ch_cyan=2, rs_ch_fireblu=2, rs_ch_gray=2, rs_ch_abyss=2)

def base_mix(fam):
    """CH dial with every extra colour on, as a 13-vector over the owner's ladder (EX folded into its colour)"""
    D, r = final_dist(fam, ALL_ON)
    v = [0.0] * 13
    for k, p in D.items():
        t = tier_of_class(k)
        if isinstance(t, str): t = int(t[2:])
        v[t - 1] += p
    s = sum(v); return [x / s for x in v]

def split_ex(fam, v):
    """returns dict colour->share plus 'EX'"""
    out = {COLS[i]: v[i] for i in range(13)}
    if fam in EXFAM:
        c = COLS[EXFAM[fam] - 1]
        out['EX'] = out[c] * EXP; out[c] *= (1 - EXP)
    else: out['EX'] = 0.0
    return out

def opt_A(fam, S):           # everything spawns exactly at colour 1+S (today's Common-only base, shifted)
    v = [0.0] * 13; v[min(12, S)] = 1.0; return v

def opt_B(fam, S):           # roll the full CH dial (extras on), then +S colours, clamped at White
    b = base_mix(fam); v = [0.0] * 13
    for i, p in enumerate(b): v[min(12, i + S)] += p
    return v

def opt_C(fam, S, below=0.55, above=0.30, boss=0.15):
    """sliding window: centre c = 1+S; weight below^(c-k) under the centre, above^(k-c) over it;
    the two boss colours carry an extra x boss factor until the centre reaches them"""
    c = 1 + S; w = []
    for k in range(1, 14):
        x = below ** (c - k) if k <= c else above ** (k - c)
        if k >= 12 and c < k: x *= boss
        w.append(x)
    s = sum(w); return [x / s for x in w]

def summary(opt, name, Smax=14):
    rows = []
    for S in range(0, Smax + 1):
        per = [split_ex(f, opt(f, S)) for f in range(17)]
        avg = {k: sum(p[k] for p in per) / 17 for k in per[0]}
        exfam = [p['EX'] for f, p in enumerate(per) if f in EXFAM]
        mean_col = sum(sum((i + 1) * opt(f, S)[i] for i in range(13)) for f in range(17)) / 17
        rows.append({'S': S, 'mean_colour': round(mean_col, 2), 'Black': avg['Black'], 'White': avg['White'],
                     'EX_all_families': avg['EX'], 'EX_in_EX_families': sum(exfam) / len(exfam),
                     'share_by_colour': {k: round(v, 4) for k, v in avg.items()}})
    return rows

if __name__ == '__main__':
    out = {}
    for nm, fn in (('A_hard_shift_from_Common', opt_A), ('B_shift_the_CH_dial', opt_B), ('C_sliding_window', opt_C)):
        out[nm] = summary(fn, nm)
        print('==', nm)
        for r in out[nm]:
            print(f"S={r['S']:2} mean={r['mean_colour']:5.2f} Black={r['Black']*100:6.2f}% White={r['White']*100:6.2f}% EX(all)={r['EX_all_families']*100:5.2f}% EX(EX fams)={r['EX_in_EX_families']*100:5.2f}%  "
                  + ' '.join(f"{k[:3]}:{v*100:.0f}" for k, v in r['share_by_colour'].items() if v >= 0.005))
    out['base_mix_all_extras_on'] = {FAMS[f]: [round(x, 4) for x in base_mix(f)] for f in range(17)}
    json.dump(out, open('/tmp/econ3/ladder/spawn_proposals.json', 'w'), indent=1)

# ---- Option D: per-family ladder reordered by measured challenge index, EX as a 14th rung where it exists ----
def opt_D_table(Smax=13):
    st = json.load(open('/tmp/econ3/ladder/ladder_stats.json'))
    order = st['ci_order_per_family']
    exf = {e['family'] for e in st['ex']}
    rows = []
    for S in range(0, Smax + 1):
        acc = {c: 0.0 for c in COLS}; acc['EX'] = 0.0
        for f in range(17):
            fam = FAMS[f]; rungs = list(order[fam]) + (['EX'] if fam in exf else [])
            n = len(rungs)
            c = 1 + S; w = []
            for k in range(1, n + 1):
                x = 0.55 ** (c - k) if k <= c else 0.30 ** (k - c)
                if k >= n - 1 and c < k: x *= 0.15       # the top two rungs stay rare until the centre reaches them
                w.append(x)
            s = sum(w)
            for k, r in enumerate(rungs): acc[r] += w[k] / s / 17
        mean_ci_rank = None
        rows.append({'S': S, 'Black': acc['Black'], 'White': acc['White'], 'EX_all_families': acc['EX'],
                     'share_by_colour': {k: round(v, 4) for k, v in acc.items()}})
    return rows, order

if __name__ == '__main__':
    rows, order = opt_D_table()
    print('== D_per_family_CI_order_window')
    for r in rows:
        print(f"S={r['S']:2} Black={r['Black']*100:6.2f}% White={r['White']*100:6.2f}% EX={r['EX_all_families']*100:5.2f}%  " + ' '.join(f"{k[:3]}:{v*100:.0f}" for k, v in r['share_by_colour'].items() if v >= 0.01))
    o = json.load(open('/tmp/econ3/ladder/spawn_proposals.json'))
    o['D_per_family_CI_order_window'] = rows; o['D_rung_order'] = order
    json.dump(o, open('/tmp/econ3/ladder/spawn_proposals.json', 'w'), indent=1)
