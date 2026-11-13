# Build tiers.json + challenge index from simulation results. Research only.
import sys, json, re, pickle, math, statistics as st
sys.path.insert(0, '/tmp/econ3/ladder/scripts')
import sim
sim.load('/tmp/econ3/ladder/scripts/rsq_classes.pkl')
from analyze import FAMS, COLS, EX, LD
R = pickle.load(open('/tmp/econ3/ladder/scripts/simres.pkl', 'rb'))

T_FIGHT = 20.0          # s
U_KITE = 4.0            # player's backpedal speed, map units/tic, while a monster closes
PLAYER_KILL_DPS = 150.0 # player's sustained damage on one target (BD22 rifle-class), for summon lifetimes
ALLY_HEAL_SHARE = 1 / 3 # sim assumed 1.5 allies in range for a radius heal; count half an ally
RAISE_EVERY = 8.0       # an A_VileChase monster raises one corpse per this many seconds when corpses exist
CORPSE_HP = 150.0       # mean HP of a raised corpse
REPO = '/home/claude/rsq_ubqseries/'

def loc(c, ln):
    f = c['file']
    if f.startswith(REPO): f = f[len(REPO):]
    elif f.startswith('/tmp/qzpk/'): f = 'QuestZDoom 17.3 ' + f[len('/tmp/qzpk/'):]
    return f'{f}:{ln}'

def propsrc(n, k):
    for c in sim.chain(n):
        if k in c['props']: return c['props'][k][0], loc(c, c['props'][k][1])
    return None, None

FLAGS = ['MISSILEMORE', 'MISSILEEVENMORE', 'QUICKTORETALIATE', 'NOPAIN', 'NOFEAR', 'BOSS', 'NOTARGET', 'REFLECTIVE',
         'INVULNERABLE', 'FLOAT', 'NORADIUSDMG', 'DONTRIP', 'NOINFIGHTING', 'SHADOW', 'GHOST', 'AVOIDMELEE', 'BOSSDEATH',
         'NODAMAGE', 'SEEINVISIBLE', 'LOOKALLAROUND', 'ALWAYSFAST', 'NEVERFAST', 'MISSILEMORE']

def static_abilities(n):
    ab = {}
    def add(k, where):
        ab.setdefault(k, where)
    seen = set()
    for c in sim.chain(n):
        if c['tag'] == 'engine' and c['name'].lower() not in ('archvile', 'painelemental', 'lostsoul'): break
        labs = sorted(c['labels'].items(), key=lambda x: x[1])
        def label_at(i):
            best = '?'
            for nm, li in labs:
                if li <= i: best = nm
            return best
        for i, f in enumerate(c['frames']):
            if 'ctl' in f: continue
            a = f.get('act', '')
            if not a: continue
            lab = label_at(i); w = loc(c, f['ln'])
            if lab in seen: pass
            L = lab.lower()
            if L in ('tickles', 'raise') or 'grow' in L or L.startswith('pain.abyss') or L.startswith('abyss') and 'grow' in L: continue
            isdeath = L.startswith(('death', 'xdeath')) or L in ('tickles',)
            for fn, args in sim.calls(a):
                fl = fn.lower(); a0 = sim.sarg(args, 0) or ''
                if fl in ('a_spawnitemex', 'a_spawnitem', 'a_custommissile', 'a_spawnprojectile') and a0:
                    if a0.lower() == 'rs_thepl anboner': continue
                    if sim.is_monster(a0) and not a0.lower().startswith('rs_colortiericon'):
                        if isdeath: add('spawns monsters on death (' + a0 + ')', w)
                        elif L.startswith('pain.abyss'): pass
                        else: add('summons (' + a0 + ')', w)
                    elif sim.is_spawner(a0) and sim.spawner_is_monster(a0):
                        add(('spawns on death' if isdeath else 'summons') + ' (random: ' + a0 + ')', w)
                    elif not isdeath and sim.spawns_monsters(a0):
                        add('summons via ' + a0 + ' (' + ', '.join(list(sim.spawns_monsters(a0))[:3]) + ')', w)
                    pi = sim.proj_info(a0) if not sim.is_monster(a0) else None
                    if pi and not isdeath:
                        if pi['dtype'] == 'ice': add('ice damage', w)
                        if pi['dtype'] == 'fire': add('fire damage', w)
                        if pi['seek']: add('homing projectiles', w)
                if isdeath: continue
                if fl in ('a_painattack', 'a_dualpainattack'): add('summons (' + (a0 or 'LostSoul') + ')', w)
                if fl == 'a_vilechase': add('resurrects corpses (A_VileChase)', w)
                if fl in ('a_raisechildren', 'a_raisesiblings'): add('resurrects its children', w)
                if fl == 'a_radiusgive':
                    if a0.lower() == 'health' or sim.is_a(a0, 'Health'): add('heals others (A_RadiusGive ' + a0 + ')', w)
                    elif re.search(r'abyss|tier', a0, re.I): add('changes others (' + a0 + ')', w)
                    else: add('buffs others (' + a0 + ')', w)
                if fl in ('healthing', 'a_resethealth'): add('self-heal', w)
                if fl == 'a_teleport': add('teleports', w)
                if fl == 'a_warp' and 'TARGET' in (a0 or '').upper(): add('warps to the player', w)
                if fl == 'thrustthingz' or (fl == 'a_changevelocity' and len(args) > 2 and re.search(r'[1-9]', args[2] or '')): add('hops/leaps', w)
                if fl == 'a_skullattack': add('charges (skull attack)', w)
                if fl == 'a_fastchase': add('strafes (A_FastChase)', w)
                if fl == 'a_customrailgun': add('railgun', w)
                if fl in ('a_setreflective', 'a_setreflectiveinvulnerable') or (fl == 'a_changeflag' and 'REFLECTIVE' in a0.upper()): add('reflects projectiles (phase)', w)
                if fl in ('a_setinvulnerable', 'a_unsetshootable') or (fl == 'a_changeflag' and re.search('INVULNERABLE|NODAMAGE', a0.upper()) and re.search(r'1|true', ' '.join(args[1:2]), re.I)): add('invulnerable phase', w)
                if fl == '=' and re.match(r'^b(INVULNERABLE|NODAMAGE)$', args[0], re.I) and re.search(r'true|1', args[2], re.I): add('invulnerable phase', w)
                if fl == '=' and re.match(r'^bREFLECTIVE$', args[0], re.I) and re.search(r'true|1', args[2], re.I): add('reflects projectiles (phase)', w)
                if fl == 'a_settranslucent' and re.match(r'^0(\.0+)?$', a0 or '1'): add('turns invisible', w)
                if fl == 'a_custombulletattack': add('hitscan', w)
    if sim.flag(n, 'REFLECTIVE'): add('reflects projectiles (always)', 'flag')
    if sim.flag(n, 'INVULNERABLE'): add('invulnerable (flag)', 'flag')
    if sim.flag(n, 'SHADOW'): add('shadow (spoils aim)', 'flag')
    return ab

def hp_of(n):
    v, src = propsrc(n, 'health')
    try: return float(sim.ev(v)), src
    except Exception: return 1000.0, src

def speed_of(n):
    v, src = propsrc(n, 'speed'); fv, fs = propsrc(n, 'fastspeed')
    out = {'speed': float(sim.ev(v) or 0) if v else 0.0, 'src': src}
    if fv and float(sim.ev(fv) or -1) > 0: out['fastspeed'] = float(sim.ev(fv)); out['fastspeed_src'] = fs
    return out

REPL = {}
def replacement(k):
    if not REPL:
        for c in sim.C.values():
            if c.get('replaces') and c['tag'] != 'engine': REPL[c['replaces'].lower()] = c['name']
    return REPL.get(k.lower(), k)

def summ_expand(sp):
    out = {}
    sp = {(replacement(k) if not k.lower().startswith('rs_') else k): v for k, v in sp.items()}
    for k, v in sp.items():
        if sim.is_spawner(k):
            for k2, p in sim.spawner_expand(k).items(): out[k2] = out.get(k2, 0) + v * p
        else: out[k] = out.get(k, 0) + v
    return out

def base_dps(n, d):
    o = R.get(n)
    return o[d]['dps'] if o and d in o else 0.0

def fight_dps(n, d, o):
    v = o[d]['speed_mean'] * o[d]['chase_frac']
    close = v - U_KITE
    c = 0.0
    if close > 0:
        tc = max(0.0, d - 56) / close / 35.0
        c = max(0.0, 1 - tc / T_FIGHT) * 0.5
    return (1 - c) * o[d]['dps'] + c * o[40]['dps'], c

def unshootable(k):
    for c in sim.chain(k):
        if 'SHOOTABLE' in c['flags']: return not c['flags']['SHOOTABLE']
    return False

def is_helper(k):
    return unshootable(k) or sim.flag(k, 'INVULNERABLE') or sim.flag(k, 'NODAMAGE')

def summon_terms(n, o):
    hp_add = 0.0; dps_add = {256: 0.0, 512: 0.0}; detail = {}
    for d in (256, 512):
        sp = summ_expand(o[d]['summ_per_s'])
        for k, rate in sp.items():
            if k.lower() == n.lower(): continue
            hpk = hp_of(k)[0] if sim.cls(k) else 100.0
            if is_helper(k): hpk = 0.0
            life = min(T_FIGHT / 2, hpk / PLAYER_KILL_DPS + 2.0)
            alive = rate * life
            if k not in R and sim.cls(k):
                import analyze as _an
                _an.sim = sim
                R[k] = _an.one(k)[1]
            dk = base_dps(k, d) if k in R else 0.0
            dps_add[d] += alive * dk
            if d == 256:
                hp_add += rate * T_FIGHT * hpk * 0.5
                detail[k] = {'per_20s': round(rate * T_FIGHT, 2), 'hp_each': hpk, 'dps_each_256': round(dk, 1),
                             'helper (unshootable/invulnerable, HP not counted)': is_helper(k),
                             'reflects': bool(sim.flag(k, 'REFLECTIVE')),
                             'its_abilities': sorted(static_abilities(k))[:6] if sim.cls(k) else []}
            else:
                hp_add += rate * T_FIGHT * hpk * 0.5
                if k in detail: detail[k]['per_20s'] = round((detail[k]['per_20s'] + rate * T_FIGHT) / 2, 2)
    return hp_add, dps_add, detail

def build_row(n, fam, tier, colour):
    o = R[n]
    hp, hsrc = hp_of(n)
    pc, pcs = propsrc(n, 'painchance')
    spd = speed_of(n)
    fl = sorted(set(f for f in FLAGS if sim.flag(n, f)))
    ab = static_abilities(n)
    tags = sorted(set(o[256]['tags']) | set(o[512]['tags']))
    hp_sum, dps_sum, sdet = summon_terms(n, o)
    heal_o = min(hp, (o[256]['heal_others_s'] + o[512]['heal_others_s']) / 2 * T_FIGHT * ALLY_HEAL_SHARE)
    heal_s = min(hp, (o[256]['heal_self_s'] + o[512]['heal_self_s']) / 2 * T_FIGHT)
    raises = 0.0
    if any('resurrect' in a for a in ab): raises = T_FIGHT / RAISE_EVERY * CORPSE_HP
    invul = min(0.6, (o[256]['invul_frac'] + o[512]['invul_frac']) / 2)
    shield = any(v.get('reflects') and v.get('helper (unshootable/invulnerable, HP not counted)') for v in sdet.values())
    for v in sdet.values():
        for a in v.get('its_abilities', []):
            if 'resurrect' in a: raises = max(raises, T_FIGHT / RAISE_EVERY * CORPSE_HP)
    ehp = (hp / (1 - invul)) * (1.25 if shield else 1.0) + hp_sum + heal_o + heal_s + raises
    f256, c256 = fight_dps(n, 256, o); f512, c512 = fight_dps(n, 512, o)
    d256 = f256 + dps_sum[256]; d512 = f512 + dps_sum[512]
    v = (o[256]['speed_mean'] + o[512]['speed_mean']) / 2
    mob = {'ground_speed_u_per_tic': round(v, 2),
           'hops': any('hop' in a for a in ab), 'charges': any('charge' in a or 'dash' in a for a in ab) or o[256]['charges_s'] > 0,
           'teleports': any('teleport' in a or 'warps' in a for a in ab), 'floats': sim.flag(n, 'FLOAT')}
    by = {k: round(vv, 1) for k, vv in sorted(o[256]['by'].items(), key=lambda x: -x[1])[:5]}
    row = {'family': FAMS[fam], 'colour': colour, 'tier': tier, 'class': n, 'hp': hp, 'hp_src': hsrc,
           'speed': spd, 'painchance': float(sim.ev(pc) or 0) if pc else 0.0, 'painchance_src': pcs, 'flags': fl,
           'attack_dps_hold_256': round(o[256]['dps'], 1), 'attack_dps_hold_512': round(o[512]['dps'], 1),
           'attack_dps_contact': round(o[40]['dps'], 1), 'attacks_per_s_256': round(o[256]['att_s'], 2),
           'dps_by_attack_256': by, 'contact_share_256': round(c256, 2), 'contact_share_512': round(c512, 2),
           'summons': sdet, 'added_threat': {'summoned_hp_20s': round(hp_sum), 'summoned_dps_256': round(dps_sum[256], 1),
                                            'summoned_dps_512': round(dps_sum[512], 1)},
           'reflecting_shield_helper': shield, 'heal_others_20s': round(heal_o), 'self_heal_20s': round(heal_s), 'raise_hp_20s': round(raises),
           'invulnerable_share': round(invul, 3), 'reflective_share': round((o[256]['refl_frac'] + o[512]['refl_frac']) / 2, 3),
           'ehp': round(ehp), 'dps_256': round(d256, 1), 'dps_512': round(d512, 1), 'mobility': mob,
           'threat_abilities': {k: w for k, w in ab.items()}, 'sim_tags': tags}
    return row

def mobility_mult(m, vref):
    x = (max(m['ground_speed_u_per_tic'], 0.5) / vref) ** 0.25
    x *= 1 + 0.10 * m['hops'] + 0.10 * m['charges'] + 0.15 * m['teleports'] + 0.05 * bool(m['floats'])
    return x

def main():
    rows = []
    for k, (c, ln) in LD['cls'].items():
        f, t = map(int, k.split(','))
        rows.append(build_row(c, f, t, COLS[t - 1]))
    for c, (f, t) in EX.items():
        rows.append(build_row(c, f, t, COLS[t - 1] + ' EX'))
    imp = [r for r in rows if r['class'] == 'RS_CommonImp'][0]
    vref = imp['mobility']['ground_speed_u_per_tic']
    def raw(r):
        dps = (r['dps_256'] + r['dps_512']) / 2
        return math.sqrt(max(r['ehp'], 1) * max(dps, 0.1)) * mobility_mult(r['mobility'], vref)
    ref = raw(imp)
    for r in rows:
        r['mobility']['multiplier'] = round(mobility_mult(r['mobility'], vref), 3)
        r['challenge_index'] = round(raw(r) / ref, 2)
        r['ci_hp_only'] = round(math.sqrt(r['hp'] / imp['hp']), 2)
    json.dump({'meta': {
        'units': 'HP in hit points; dps = expected damage to the player per second before skill DamageFactor; speed u/tic',
        'black_metal': 'MonsterHealth 0.80 and DamageFactor 1.5 (bd22src/MAPINFO.txt:91-92) scale every class alike: '
                       'multiply ehp by 0.8 and dps by 1.5; the challenge index moves by the same factor sqrt(1.2) for all',
        'model': 'see report; constants in scripts/sim.py and scripts/build.py',
        'ci_reference': 'RS_CommonImp = 1.00'}, 'rows': rows}, open('/tmp/econ3/ladder/tiers.json', 'w'), indent=1)
    print(len(rows))

if __name__ == '__main__':
    main()
