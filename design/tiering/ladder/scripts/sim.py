# Monte-Carlo state-machine simulator for Doom-family monsters (ZScript/DECORATE parsed by parse.py).
# Estimates expected damage to a player at a held distance, summons, heals, invulnerable time, mobility.
# Research tool only.  All model assumptions are constants at the top.
import re, math, random, pickle, json, sys

# ---------------- model constants (documented in the report) ----------------
PLAYER_R = 16.0          # player radius (32 wide)
PLAYER_HALF_H = 28.0     # half of 56 height
V_DODGE = 8.0            # player's lateral displacement at arrival ~ Uniform(-V*tau, +V*tau), tau = flight - reaction (map units/tic)
T_REACT = 6.0            # tics before a player reacts to a projectile
SEEK_FLOOR = 0.65        # seeking projectiles hit at least this often
LEAD_FLOOR = 0.55        # leading shots
P_SIGHT_BREAK = 0.12     # chance per refire check that the player breaks line of sight (ends a refire loop)
HIT_RATE = 2.5           # player hits on the monster per second (drives pain interrupts)
FIGHT_T = 20 * 35        # fight window in tics
RUNS = 40                # Monte-Carlo runs per class per range
CHILD_LIFE = 8 * 35      # summoned child counted alive this long (for CheckProximity caps)
FAST = True              # Black Metal = FastMonsters

CV_DEFAULTS = {'rs_ch_brown': 1, 'rs_ch_cyan': 1, 'rs_ch_fireblu': 1, 'rs_ch_gray': 1, 'rs_ch_abyss': 1,
               'rs_ch_blackboss': 1, 'rs_ch_whiteboss': 1, 'rs_ch_exboss': 1, 'rs_ch_nerfredboss': 1,
               'rs_ch_yellowrev': 0, 'rs_ch_intercept': 0, 'rs_ch_cyanbounce': 0, 'rs_ch_rawket': 1, 'rs_ch_abyssmark': 0}

C = {}
def load(*pk):
    for p in pk:
        C.update(pickle.load(open(p, 'rb')))

def cls(n):
    if n is None: return None
    return C.get(str(n).lower().strip('"'))

def chain(n, depth=0):
    c = cls(n)
    out = []
    while c and depth < 20:
        out.append(c); c = cls(c['parent']); depth += 1
    return out

def prop(n, k, default=None):
    for c in chain(n):
        if k in c['props']: return c['props'][k]
    return (default, None)

def flag(n, f):
    for c in chain(n):
        if f in c['flags']: return c['flags'][f]
    return False

def is_a(n, base):
    return any(c['name'].lower() == base.lower() for c in chain(n))

def is_monster(n):
    return flag(n, 'ISMONSTER') or flag(n, 'MONSTER') or flag(n, 'COUNTKILL')

def is_spawner(n):
    return is_a(n, 'RandomSpawner')

# ---------------- expressions ----------------
FLAGVALS = {'CMF_AIMOFFSET': 1, 'CMF_AIMDIRECTION': 2, 'CMF_TRACKOWNER': 4, 'CMF_CHECKTARGETDEAD': 8, 'CMF_ABSOLUTEPITCH': 16,
            'CMF_OFFSETPITCH': 32, 'CMF_SAVEPITCH': 64, 'CMF_ABSOLUTEANGLE': 128, 'CBAF_AIMFACING': 1, 'CBAF_NORANDOM': 2,
            'CBAF_EXPLICITANGLE': 4, 'CBAF_NOPITCH': 8, 'CBAF_NORANDOMPUFFZ': 16, 'SXF_ABSOLUTEANGLE': 1 << 3,
            'SXF_ABSOLUTEVELOCITY': 1 << 5, 'SXF_ABSOLUTEPOSITION': 1 << 4}
def _rand(a, b=None):
    if b is None: return random.randint(0, 255) if a is None else a
    a, b = float(a), float(b)
    if a > b: a, b = b, a
    if a == int(a) and b == int(b): return random.randint(int(a), int(b))
    return random.uniform(a, b)
def _frand(a, b):
    a, b = float(a), float(b)
    return random.uniform(min(a, b), max(a, b))

class Env:
    def __init__(s, vars_, d, health_frac, maxhp):
        s.vars = vars_; s.d = d; s.hf = health_frac; s.maxhp = maxhp

def py_expr(e):
    x = e.strip()
    x = re.sub(r'RS_Zom\.CV\(\s*\'(\w+)\'\s*,\s*(-?\d+)\s*\)', lambda m: str(CV_DEFAULTS.get(m.group(1), int(m.group(2)))), x)
    x = re.sub(r'\bf?random\s*\[\s*\w*\s*\]\s*\(', lambda m: ('_frand(' if m.group(0).lstrip().lower().startswith('f') else '_rand('), x, flags=re.I)
    x = re.sub(r'\bfrandom\s*\(', '_frand(', x, flags=re.I)
    x = re.sub(r'\brandom\s*\(', '_rand(', x, flags=re.I)
    x = re.sub(r'\brandom2\s*\(\s*\)', '(_rand(0,255)-_rand(0,255))', x, flags=re.I)
    x = x.replace('&&', ' and ').replace('||', ' or ')
    x = re.sub(r'!(?!=)', ' not ', x)
    x = re.sub(r'\btrue\b', 'True', x, flags=re.I); x = re.sub(r'\bfalse\b', 'False', x, flags=re.I)
    x = re.sub(r'\bnull\b', 'None', x, flags=re.I)
    # ternary a ? b : c  (simple, non-nested)
    m = re.match(r'^\(?\s*(.+?)\s*\?\s*(.+?)\s*:\s*(.+?)\s*\)?$', x)
    if m and '?' in x: x = f'(({m.group(2)}) if ({m.group(1)}) else ({m.group(3)}))'
    return x

def ev(e, env=None, default=0):
    if e is None: return default
    e = str(e).strip()
    if e == '': return default
    if re.fullmatch(r'-?\d+(\.\d+)?', e): return float(e)
    m0 = re.match(r'^(-?\d+(?:\.\d+)?)\s+[A-Za-z"]', e)
    if m0: return float(m0.group(1))
    x = py_expr(e)
    loc = {'_rand': _rand, '_frand': _frand, 'abs': abs, 'min': min, 'max': max, 'None': None, 'MELEEDELTA': 20, 'DEFAULT_HEALTH': 1000}
    for k, v in FLAGVALS.items(): loc[k] = v
    if env:
        for k, v in env.vars.items(): loc[k] = v
        loc['health'] = env.hf * env.maxhp
    try:
        # unknown identifiers -> 0
        for name in set(re.findall(r'\b[A-Za-z_]\w*\b', x)):
            if name not in loc and name not in ('and', 'or', 'not', 'if', 'else', 'True', 'False', 'None', 'int', 'float'):
                loc[name] = 0 if not name.lower().startswith('user_') else env.vars.get(name.lower(), 0) if env else 0
        lo = {k.lower(): v for k, v in loc.items()}; lo.update(loc)
        return eval(x, {'__builtins__': {}, 'int': int, 'float': float}, lo)
    except Exception:
        return default

def mean_expr(e, n=200):
    if e is None: return 0.0
    vals = []
    for _ in range(n):
        v = ev(e)
        try: vals.append(float(v))
        except Exception: vals.append(0.0)
    return sum(vals) / len(vals)

# ---------------- call parsing ----------------
def split_args(s):
    out = []; depth = 0; cur = ''; instr = False
    for ch in s:
        if instr:
            cur += ch
            if ch == '"': instr = False
            continue
        if ch == '"': instr = True; cur += ch; continue
        if ch in '([': depth += 1
        if ch in ')]': depth -= 1
        if ch == ',' and depth == 0: out.append(cur.strip()); cur = ''; continue
        cur += ch
    if cur.strip() != '' or out: out.append(cur.strip())
    return out

CALL = re.compile(r'([A-Za-z_][\w\.]*)\s*\(')
def calls(act):
    """returns list of (fname, args[] raw) and assignments in blocks"""
    res = []
    if not act: return res
    a = act.strip()
    if a.startswith('{'): a = a.strip('{} ')
    stmts = []; depth = 0; cur = ''; instr = False
    for ch in a:
        if instr:
            cur += ch
            if ch == '"': instr = False
            continue
        if ch == '"': instr = True; cur += ch; continue
        if ch == '(': depth += 1
        if ch == ')': depth -= 1
        if ch == ';' and depth == 0: stmts.append(cur.strip()); cur = ''; continue
        cur += ch
    if cur.strip(): stmts.append(cur.strip())
    for st in stmts:
        m = re.match(r'^(user_\w+|b\w+)\s*(\+=|-=|=)\s*(.+)$', st, re.I)
        if m:
            res.append(('=', [m.group(1), m.group(2), m.group(3)])); continue
        m = re.match(r'^return\s+ResolveState\s*\(\s*"(\w+)"\s*\)', st, re.I)
        if m: res.append(('goto', [m.group(1)])); continue
        m = re.match(r'^if\s*\((.+)\)\s*return\s+ResolveState\s*\(\s*"([\w\.]+)"\s*\)', st, re.I)
        if m: res.append(('ifgoto', [m.group(1), m.group(2)])); continue
        m = CALL.match(st)
        if m:
            name = m.group(1); depth = 0; j = m.end() - 1; k = j
            while k < len(st):
                if st[k] == '(': depth += 1
                elif st[k] == ')':
                    depth -= 1
                    if depth == 0: break
                k += 1
            res.append((name, split_args(st[j + 1:k])))
        elif re.match(r'^[A-Za-z_]\w*$', st):
            res.append((st, []))
    return res

def sarg(a, i, default=None):
    if i < len(a) and a[i] not in ('', None):
        v = a[i].strip()
        if v.startswith('"') and v.endswith('"'): return v[1:-1]
        return v
    return default

# ---------------- state machine ----------------
def resolve_label(n, label, owner_name=None):
    """dynamic lookup: returns (classname, index) of first real frame"""
    label = label.strip('"').lower()
    ofs = 0
    m = re.match(r'^([\w\.:]+)\s*\+\s*(\d+)$', label)
    if m: label, ofs = m.group(1), int(m.group(2))
    if label.startswith('super::'):
        label = label[7:]
        ch = chain(owner_name or n)[1:]
    else:
        ch = chain(n)
    for c in ch:
        if label in c['labels']:
            return advance(c['name'], c['labels'][label], ofs)
        # dotted labels fall back to the base (Pain.Foo -> Pain)
    if '.' in label:
        return resolve_label(n, label.split('.')[0] + ('+%d' % ofs if ofs else ''), owner_name)
    return None

def advance(cn, idx, ofs):
    c = cls(cn); fr = c['frames']; k = idx; cnt = 0
    while k < len(fr):
        if 'ctl' in fr[k]:
            k += 1; continue
        if cnt == ofs: return (cn, k)
        cnt += 1; k += 1
    return None

def static_goto(cn, idx):
    """frame idx done -> next position (owner-static gotos)"""
    c = cls(cn); fr = c['frames']; k = idx + 1
    if k >= len(fr): return None
    f = fr[k]
    if 'ctl' not in f: return (cn, k)
    t = f['ctl']
    if t == 'stop' or t == 'fail': return None
    if t == 'wait': return (cn, idx)
    if t == 'loop':
        best = 0
        for nm, li in c.get('label_order', []):
            if li <= idx: best = li
        return advance(cn, best, 0)
    if t == 'goto':
        tgt = f['target'] or ''
        lab = tgt + ('+%d' % f['ofs'] if f['ofs'] else '')
        if '::' in tgt and not tgt.lower().startswith('super::'):
            k2 = tgt.split('::'); return resolve_label(k2[0], k2[1] + ('+%d' % f['ofs'] if f['ofs'] else ''))
        r = resolve_label(cn, lab, cn)
        return r
    return None

# ---------------- projectile info ----------------
PI = {}
def proj_info(pn):
    k = str(pn).lower()
    if k in PI: return PI[k]
    PI[k] = None
    c = cls(pn)
    if not c: PI[k] = None; return None
    dmgf = prop(pn, 'damagefunction')[0]; dmg = prop(pn, 'damage')[0]
    if dmgf: dm = mean_expr(dmgf)
    elif dmg:
        v = dmg.strip()
        if v.startswith('('): dm = mean_expr(v)
        else:
            try: dm = float(v) * 4.5
            except Exception: dm = mean_expr(v) * 4.5
    else: dm = 0.0
    spd = fast_or_speed(pn)
    rad = float(ev(prop(pn, 'radius', '8')[0]) or 8)
    dtype = (prop(pn, 'damagetype')[0] or '').strip('"').lower()
    seek = False; expl = (0, 0); flight = []; kids = []; trail = 0.0
    ripper = flag(pn, 'RIPPER')
    for cc in chain(pn):
        for lab, li in cc['labels'].items():
            pass
    # walk spawn and death sequences of the actual class (resolved)
    def walk(label, maxn=60):
        r = resolve_label(pn, label); out = []; seen = set(); n = 0
        while r and n < maxn and r not in seen:
            seen.add(r); f = cls(r[0])['frames'][r[1]]; out.append(f); n += 1
            r = static_goto(r[0], r[1])
        return out
    spawn = walk('spawn'); death = walk('death') or walk('crash')
    turn = 0.0; per = 0.0
    if flag(pn, 'SEEKERMISSILE') or True:
        loop_t = sum(max(0, f2['tics']) for f2 in spawn) or 1
        for f in spawn:
            for fn, a in calls(f.get('act', '')):
                fl2 = fn.lower()
                if fl2 == 'a_seekermissile' and flag(pn, 'SEEKERMISSILE'):
                    turn += float(ev(sarg(a, 1, '0')) or 0)
                elif fl2 == 'a_tracer':
                    turn += 16.875 / 2
                elif fl2 == 'a_tracer2':
                    turn += float(ev(sarg(a, 0, '16.875')) or 16.875)
                elif fl2 in ('a_homingmissile',):
                    turn += 10
        if turn > 0:
            seek = True; per = turn / loop_t
    ftot = 0.0; frad = 0.0
    for f in spawn:
        for fn, a in calls(f.get('act', '')):
            if fn.lower() == 'a_explode':
                ed = mean_expr(sarg(a, 0, '-1')); er = mean_expr(sarg(a, 1, '-1'))
                if ed < 0: ed = 128
                if er < 0: er = 128
                ftot += ed; frad = max(frad, er)
    if ftot > 0:
        loop_t = sum(max(0, f2['tics']) for f2 in spawn) or 1
        flight.append((ftot / loop_t, frad))   # explode damage per tic of flight, radius
    for f in death:
        for fn, a in calls(f.get('act', '')):
            fl = fn.lower()
            if fl == 'a_explode' and expl == (0, 0):
                ed = mean_expr(sarg(a, 0, '-1')); er = mean_expr(sarg(a, 1, '-1'))
                if ed < 0: ed = 128
                if er < 0: er = 128
                expl = (ed, er)
            elif fl in ('a_spawnitemex', 'a_custommissile', 'a_spawnprojectile'):
                kn = sarg(a, 0)
                if kn and kn.lower() != k:
                    ki = proj_info(kn)
                    if ki and (ki['dm'] > 0 or ki['expl'][0] > 0):
                        kids.append(ki['dm'] + ki['expl'][0] * 0.5)
    # vanilla natives in death states
    if pn.lower() in ('rocket',) and expl == (0, 0): expl = (128, 128)
    info = {'turn': per if seek else 0.0, 'name': c['name'], 'dm': dm, 'spd': spd, 'rad': rad, 'seek': seek, 'expl': expl, 'flight': flight,
            'kids': kids, 'dtype': dtype, 'ripper': ripper, 'file': c['file'], 'line': c['line']}
    PI[k] = info
    return info

def fast_or_speed(n):
    try: sp = float(ev(prop(n, 'speed', '0')[0]) or 0)
    except Exception: sp = 0.0
    if FAST:
        fs = prop(n, 'fastspeed')[0]
        try:
            v = float(ev(fs)) if fs is not None else -1
            if v > 0: return v
        except Exception: pass
    return sp

def tri_p(a, s):
    """P(|X|<a) for triangular X on [-s,s]"""
    if s <= 0: return 1.0
    if a >= s: return 1.0
    return 1 - (1 - a / s) ** 2

def geo_hit(theta_deg, d, w):
    return 1.0 if abs(d * math.tan(math.radians(min(abs(theta_deg), 89)))) <= w else 0.0

def p_lat(x, w, s):
    """P(|y - x| < w) with player lateral displacement y ~ Uniform(-s, s); s=0 -> indicator"""
    x = abs(x)
    if s < 0.5: return 1.0 if x <= w else 0.0
    lo = max(-s, x - w); hi = min(s, x + w)
    return max(0.0, hi - lo) / (2 * s)

def tau(d, spd, since_face=0):
    if spd <= 0: return None
    return max(0.0, d / spd + since_face - T_REACT)

def seek_floor(turn):
    return min(0.75, 0.15 + 0.15 * turn)

def p_dodge(d, spd, w, seek=False, lead=False, since_face=0):
    """single projectile aimed dead-on (kept for melee-less natives)"""
    ta = tau(d, spd, since_face)
    if ta is None: return 0.0
    p = p_lat(0, w, V_DODGE * ta)
    if seek: p = max(p, seek_floor(float(seek)))
    if lead: p = max(p, LEAD_FLOOR)
    return p

def proj_expect(pi, d, theta_samples, pitch_abs=0.0, since_face=0, lead=False, speed_override=None):
    """expected damage to player of one projectile fired at angle offsets theta_samples (deg, sampled)"""
    if not pi: return 0.0, 0.0
    spd = speed_override if speed_override is not None else pi['spd']
    ta = tau(d, spd, since_face)
    if ta is None: return 0.0, 0.0
    S = V_DODGE * ta
    w = PLAYER_R + pi['rad']
    xs = [d * math.tan(math.radians(max(-89, min(89, t)))) if abs(t) < 89 else 1e9 for t in theta_samples]
    pdir = sum(p_lat(x, w, S) for x in xs) / len(xs)
    if pitch_abs > 0.5:
        pdir *= min(1.0, math.degrees(math.atan2(PLAYER_HALF_H + pi['rad'], d)) / pitch_abs)
    if pi['seek']:
        fl = seek_floor(pi['turn'])
        # a homing shot fired roughly at the player (within 60 deg) is caught at the floor rate
        cone = sum(1 for t in theta_samples if abs(t) < 60) / len(theta_samples)
        pdir = max(pdir, fl * cone)
    if lead: pdir = max(pdir, LEAD_FLOOR * sum(p_lat(x, w, 0) for x in xs) / len(xs))
    direct = pi['dm'] * pdir
    sp = 0.0
    ed, er = pi['expl']
    if ed > 0:
        pr = sum(p_lat(x, er, S) for x in xs) / len(xs)
        pnear = max(0.0, pr - pdir)
        sp = ed * 0.85 * pdir + ed * 0.35 * 0.25 * pnear
    flt = 0.0
    for rate, fr in pi['flight']:
        # the player is inside the blast radius for about 2r/speed tics of a pass; linear falloff ~ half damage
        pin = sum(p_lat(x, fr, S) for x in xs) / len(xs)
        if spd > 0: flt += pin * rate * 0.5 * min(2 * fr / spd, 35.0)
    kd = sum(pi['kids']) * 0.15 * (pdir + 0.3 * (1 - pdir)) if pi['kids'] else 0.0
    return direct + sp + flt + kd, pdir

# ---------------- vanilla natives ----------------
NATIVE_PROJ = {'a_troopattack': 'DoomImpBall', 'a_headattack': 'CacodemonBall', 'a_bruisattack': 'BaronBall',
               'a_skelmissile': 'RevenantTracer', 'a_bspiattack': 'ArachnotronPlasma', 'a_cyberattack': 'Rocket'}
NATIVE_MELEE = {'a_troopattack': 13.5, 'a_headattack': 35, 'a_bruisattack': 45, 'a_skelfist': 33, 'a_sargattack': 22}

# ---------------- the simulator ----------------
class Res:
    def __init__(s):
        s.dmg = 0.0; s.t = 0; s.summ = {}; s.heal_others = 0.0; s.heal_self = 0.0; s.invul_t = 0; s.refl_t = 0
        s.teleports = 0; s.hops = 0; s.charges = 0; s.raises = 0; s.attacks = 0; s.chase_t = 0; s.chase_calls = 0
        s.dmg_by = {}; s.volleys = []; s.tags = set(); s.selfkill = 0; s.retier = 0; s.speed_t = 0.0

def run(n, d, T=FIGHT_T, seed=None, start='see', res=None, maxhp=None):
    if seed is not None: random.seed(seed)
    res = res or Res()
    mh = maxhp or float(ev(prop(n, 'health', '1000')[0]) or 1000)
    vars_ = {}
    for c in reversed(chain(n)):
        for k in c['uservars']: vars_[k] = 0
    env = Env(vars_, d, 1.0, mh)
    flags = {}
    def fl(f):
        if f in flags: return flags[f]
        return flag(n, f)
    inv = {}
    children = []  # (spawn time, class)
    pos = resolve_label(n, start) or resolve_label(n, 'spawn')
    meleestate = resolve_label(n, 'melee'); missilestate = resolve_label(n, 'missile')
    mr = float(ev(prop(n, 'meleerange', '64')[0]) or 64)
    mmc = float(ev(prop(n, 'minmissilechance', '200')[0]) or 200)
    mtr = float(ev(prop(n, 'maxtargetrange', '0')[0]) or 0)
    pc = float(ev(prop(n, 'painchance', '0')[0]) or 0)
    spd0 = fast_or_speed(n)
    curspd = spd0
    painstate = resolve_label(n, 'pain')
    t = 0.0; justattacked = False; justhit = False; last_face = 0.0; zero = 0
    skullfly_end = None; in_pain = False
    while t < T and pos:
        env.hf = max(0.05, 1.0 - 0.95 * t / T)
        cn, idx = pos
        f = cls(cn)['frames'][idx]
        jumped = None
        for fn, a in calls(f.get('act', '')):
            ctx = {'ja': justattacked, 'jh': justhit, 'face': last_face, 'spd': curspd, 'skull': skullfly_end, 'idx': idx}
            r = do_call(n, cn, fn, a, env, d, res, t, last_face, flags, inv, children, mr, mmc, mtr,
                        meleestate, missilestate, fl, ctx)
            justattacked = ctx['ja']; justhit = ctx['jh']; last_face = ctx['face']; curspd = ctx['spd']; skullfly_end = ctx['skull']
            if r == 'STOP': pos = None; break
            if r:
                jumped = r; break
        if pos is None: break
        if jumped:
            pos = jumped; zero += 1
            if zero > 400: break
            continue
        tics = f['tics']
        if tics < 0:
            # infinite frame: end of a sequence (death / idle)
            break
        if FAST and f.get('fast') and tics > 0: tics = max(1, tics // 2)
        if tics == 0:
            zero += 1
            if zero > 400: break
            pos = static_goto(cn, idx); continue
        zero = 0
        # pain interrupts within this frame (Poisson hits)
        lam = HIT_RATE / 35.0
        pain_at = None
        if pc > 0 and not fl('NOPAIN') and painstate and not in_pain and not fl('INVULNERABLE') and not fl('NODAMAGE'):
            tt = 0.0
            while True:
                tt += random.expovariate(lam)
                if tt >= tics: break
                if random.random() * 256 < pc: pain_at = tt; break
        if fl('INVULNERABLE') or fl('NODAMAGE') or (not fl('SHOOTABLE') and 'SHOOTABLE' in flags): res.invul_t += tics
        if fl('REFLECTIVE'): res.refl_t += tics
        if pain_at is not None:
            t += pain_at
            if 'chase' in f.get('act', '').lower(): res.chase_t += pain_at
            pos = painstate; justhit = True; in_pain = True
            continue
        t += tics
        if re.search(r'a_(fast|vile)?chase', f.get('act', ''), re.I):
            res.chase_t += tics; res.speed_t += curspd
        nxt = static_goto(cn, idx)
        if skullfly_end is not None and t >= skullfly_end:
            skullfly_end = None; nxt = resolve_label(n, 'see')
        if nxt and in_pain:
            # leaving pain when we hit a chase frame again
            nf = cls(nxt[0])['frames'][nxt[1]]
            if 'chase' in nf.get('act', '').lower(): in_pain = False
        pos = nxt
    res.t += min(t, T) if t > 0 else T
    return res

def chase(n, a, env, d, res, ctx, mr, mmc, mtr, meleestate, missilestate, fl):
    res.chase_calls += 1
    ms = meleestate; xs = missilestate
    if len(a) >= 1 and a[0] not in ('',):
        v = a[0].strip('"')
        if v.lower() in ('null', 'none', '_'): ms = None
        elif v: ms = resolve_label(n, v) or ms
    if len(a) >= 2 and a[1] not in ('',):
        v = a[1].strip('"')
        if v.lower() in ('null', 'none', '_'): xs = None
        elif v: xs = resolve_label(n, v) or xs
    if ctx['ja']:
        ctx['ja'] = False; return None
    if ms and d < mr + PLAYER_R:
        ctx['ja'] = True; return ms
    if xs:
        if ctx['jh']:
            ctx['jh'] = False; ctx['ja'] = True; return xs
        if mtr > 0 and d > mtr: return None
        dist = d - 64 - (0 if ms else 128)
        if fl('MISSILEMORE'): dist *= 0.5
        if fl('MISSILEEVENMORE'): dist *= 0.125
        if random.randint(0, 255) >= min(int(max(dist, 0)), int(mmc)):
            ctx['ja'] = True; return xs
    return None

def add_dmg(res, key, v):
    res.dmg += v; res.dmg_by[key] = res.dmg_by.get(key, 0) + v

def angle_samples(expr, n=48, env=None):
    return [float(ev(expr, env, 0) or 0) for _ in range(n)]

def summon(res, sc, k=1.0, t=0, children=None):
    if not sc: return
    res.summ[sc] = res.summ.get(sc, 0) + k
    if children is not None: children.append((t, sc.lower()))

def do_call(n, cn, fn, a, env, d, res, t, last_face, flags, inv, children, mr, mmc, mtr, meleestate, missilestate, fl, ctx):
    f = fn.lower()
    if f == '=':
        var, op, val = a
        v = ev(val, env, 0)
        if var.lower().startswith('b'):
            flags[var[1:].upper()] = bool(v)
            if var[1:].upper() in ('INVULNERABLE', 'NODAMAGE'): res.tags.add('invulnerable phase')
            if var[1:].upper() == 'REFLECTIVE': res.tags.add('reflects')
        else:
            k = var.lower(); cur = env.vars.get(k, 0)
            try:
                env.vars[k] = cur + v if op == '+=' else cur - v if op == '-=' else v
            except Exception: pass
        return None
    if f == 'goto':
        return resolve_label(n, a[0])
    if f == 'ifgoto':
        return resolve_label(n, a[1]) if ev(a[0], env, False) else None
    if f in ('a_chase', 'a_fastchase', 'a_vilechase'):
        if f == 'a_fastchase': res.tags.add('strafes (A_FastChase)')
        if f == 'a_vilechase': res.tags.add('resurrects (A_VileChase)')
        return chase(n, a, env, d, res, ctx, mr, mmc, mtr, meleestate, missilestate, fl)
    if f in ('a_facetarget', 'a_face'):
        ctx['face'] = t; return None
    since = max(0.0, t - ctx['face'])
    # ----------- control -----------
    if f == 'a_jump':
        ch = ev(sarg(a, 0, '0'), env, 0)
        labs = [x for x in a[1:]]
        try: ch = float(ch)
        except Exception: ch = 0
        if labs and random.randint(0, 255) < ch:
            tgt = random.choice(labs).strip()
            if re.fullmatch(r'-?\d+', tgt):
                return advance_rel(cn, ctx.get('idx', 0), int(tgt))
            return resolve_label(n, tgt.strip('"'))
        return None
    if f == 'a_jumpif':
        return resolve_label(n, sarg(a, 1, 'see')) if ev(a[0], env, False) else None
    if f in ('a_jumpifcloser', 'a_jumpiftargetcloser'):
        dist = float(ev(sarg(a, 0, '0'), env, 0) or 0)
        return resolve_label(n, sarg(a, 1)) if d < dist else None
    if f == 'a_jumpifhealthlower':
        h = float(ev(sarg(a, 0, '0'), env, 0) or 0)
        return resolve_label(n, sarg(a, 1)) if env.hf * env.maxhp < h else None
    if f == 'a_jumpifinventory':
        item = sarg(a, 0, '').lower(); amt = float(ev(sarg(a, 1, '0'), env, 0) or 0)
        have = inv.get(item, 0)
        if amt == 0: amt = maxamt(item)
        return resolve_label(n, sarg(a, 2)) if have >= amt and have > 0 else None
    if f in ('a_jumpifintargetlos', 'a_jumpiftargetinlos'):
        dm = float(ev(sarg(a, 3, '0'), env, 0) or 0)
        if dm > 0 and d > dm: return None
        return resolve_label(n, sarg(a, 0))
    if f == 'a_checklof':
        return resolve_label(n, sarg(a, 0))
    if f == 'a_checkrange':
        dist = float(ev(sarg(a, 0, '0'), env, 0) or 0)
        return resolve_label(n, sarg(a, 1)) if d > dist else None
    if f == 'a_checkfloor':
        return None if (fl('FLOAT') or fl('NOGRAVITY')) else resolve_label(n, sarg(a, 0))
    if f == 'a_checkproximity':
        kc = sarg(a, 1, '').lower(); cnt = float(ev(sarg(a, 3, '1'), env, 1) or 1)
        fls = sarg(a, 4, '') or ''
        if 'DEADONLY' in fls.upper(): found = 0
        else: found = sum(1 for (tt, c2) in children if c2 == kc and t - tt < CHILD_LIFE)
        less = 'LESSOREQUAL' in fls.upper()
        ok = (found <= cnt) if less else (found >= cnt)
        return resolve_label(n, sarg(a, 0)) if ok else None
    if f in ('a_monsterrefire', 'a_spidrefire', 'a_cposrefire'):
        if random.random() < P_SIGHT_BREAK:
            tgt = sarg(a, 1) if f == 'a_monsterrefire' else 'see'
            return resolve_label(n, tgt or 'see')
        return None
    if f in ('a_checksight', 'a_checkblock', 'a_checkflag', 'a_jumpifhigherorlower', 'a_jumpifmastercloser',
             'a_jumpifintargetinventory', 'a_checksightorrange', 'a_checkspecies', 'a_jumpiftracercloser'):
        return None
    # ----------- bookkeeping -----------
    if f == 'a_giveinventory':
        item = sarg(a, 0, '').lower(); amt = float(ev(sarg(a, 1, '1'), env, 1) or 1)
        if item == 'health': res.heal_self += amt
        inv[item] = min(maxamt(item), inv.get(item, 0) + amt); return None
    if f == 'a_takeinventory':
        item = sarg(a, 0, '').lower(); amt = float(ev(sarg(a, 1, '0'), env, 0) or 0)
        inv[item] = 0 if amt == 0 else max(0, inv.get(item, 0) - amt); return None
    if f == 'a_setuservar':
        env.vars[sarg(a, 0, '').lower()] = ev(sarg(a, 1, '0'), env, 0); return None
    if f == 'a_changeflag':
        fg = sarg(a, 0, '').upper(); v = ev(sarg(a, 1, '0'), env, 0)
        flags[fg] = bool(v)
        if fg in ('INVULNERABLE', 'NODAMAGE') and v: res.tags.add('invulnerable phase')
        if fg == 'REFLECTIVE' and v: res.tags.add('reflects')
        return None
    if f in ('a_setinvulnerable',): flags['INVULNERABLE'] = True; res.tags.add('invulnerable phase'); return None
    if f in ('a_unsetinvulnerable',): flags['INVULNERABLE'] = False; return None
    if f == 'a_setreflective': flags['REFLECTIVE'] = True; res.tags.add('reflects'); return None
    if f == 'a_unsetreflective': flags['REFLECTIVE'] = False; return None
    if f == 'a_setreflectiveinvulnerable':
        flags['REFLECTIVE'] = True; flags['INVULNERABLE'] = True; res.tags.add('reflects'); res.tags.add('invulnerable phase'); return None
    if f == 'a_unsetreflectiveinvulnerable':
        flags['REFLECTIVE'] = False; flags['INVULNERABLE'] = False; return None
    if f == 'a_unsetshootable': flags['SHOOTABLE'] = False; res.tags.add('invulnerable phase (unshootable)'); return None
    if f == 'a_setshootable': flags['SHOOTABLE'] = True; return None
    if f == 'a_setspeed':
        try: ctx['spd'] = float(ev(sarg(a, 0, '0'), env, 0))
        except Exception: pass
        return None
    if f in ('a_teleport',): res.teleports += 1; res.tags.add('teleports'); return None
    if f == 'a_warp':
        p = (sarg(a, 0, '') or '').upper()
        if 'TARGET' in p: res.teleports += 1; res.tags.add('warps to target')
        return None
    if f in ('thrustthingz', 'a_changevelocity', 'thrustthing'):
        zv = 0.0; xv = 0.0
        if f == 'thrustthingz': zv = float(ev(sarg(a, 1, '0'), env, 0) or 0)
        elif f == 'a_changevelocity':
            xv = float(ev(sarg(a, 0, '0'), env, 0) or 0); zv = float(ev(sarg(a, 2, '0'), env, 0) or 0)
        else: xv = float(ev(sarg(a, 1, '0'), env, 0) or 0)
        if zv > 3: res.hops += 1; res.tags.add('hops')
        if abs(xv) > 8: res.charges += 1; res.tags.add('dashes')
        return None
    if f == 'a_radiusgive':
        item = sarg(a, 0, '').lower(); amt = float(ev(sarg(a, 3, '1'), env, 1) or 1)
        rad = float(ev(sarg(a, 1, '0'), env, 0) or 0)
        if item == 'health' or is_a(item, 'Health'):
            allies = 1.5 if rad >= 300 else 0.7
            hv = amt if item == 'health' else amt * float(ev(prop(item, 'inventory.amount', '1')[0]) or 1)
            res.heal_others += hv * allies; res.tags.add('heals others')
        elif 'speed' in item: res.tags.add('buffs allies (speed)')
        elif re.search(r'retier|abyss|tier', item): res.tags.add('changes allies tier'); res.retier += 1
        else: res.tags.add('gives allies ' + sarg(a, 0, ''))
        return None
    if f == 'healthing':
        res.heal_self += float(ev(sarg(a, 0, '0'), env, 0) or 0); res.tags.add('self-heal'); return None
    if f == 'a_resethealth':
        res.heal_self += env.maxhp * (1 - env.hf); res.tags.add('self-heal'); return None
    if f in ('a_die', 'a_killmaster') and f == 'a_die':
        res.selfkill += 1; return 'STOP'
    if f in ('a_raisechildren', 'a_raisesiblings', 'a_raiseself'):
        res.raises += 1; res.tags.add('resurrects'); return None
    if f == 'a_skullattack':
        sp = float(ev(sarg(a, 0, '20'), env, 20) or 20)
        dmv = prop(n, 'damage', '3')[0]; dmean = float(ev(dmv, None, 3) or 3) * 4.5 if dmv and not str(dmv).startswith('(') else mean_expr(dmv)
        w = PLAYER_R + float(ev(prop(n, 'radius', '16')[0]) or 16)
        p = p_dodge(d, sp, w, since_face=since)
        add_dmg(res, 'SkullAttack', dmean * p); res.attacks += 1; res.charges += 1; res.tags.add('charges (skull attack)')
        ctx['skull'] = t + d / sp + 2
        return None
    # ----------- attacks -----------
    if f in ('a_custommissile', 'a_spawnprojectile'):
        pn = sarg(a, 0); pi = proj_info(pn) if pn else None
        if pi is None:
            if pn and is_monster(pn): summon(res, pn, 1, t, children); res.tags.add('summons')
            return None
        flg = int(ev(sarg(a, 4, '0'), env, 0) or 0)
        ang = sarg(a, 3, '0')
        pitch = abs(float(ev(sarg(a, 5, '0'), env, 0) or 0))
        samples = angle_samples(ang, 32, env)
        if flg & 128: samples = [random.uniform(-180, 180) + x * 0 for x in samples]
        pabs = pitch if (flg & (2 | 16 | 32)) else 0.0
        sf = since if flg & 2 else 0
        e, p = proj_expect(pi, d, samples, pabs, sf)
        add_dmg(res, pi['name'], e); res.attacks += 1
        if pi['dtype'] in ('ice', 'fire', 'plasma', 'electric', 'poison'): res.tags.add(pi['dtype'] + ' damage')
        if pi['seek']: res.tags.add('homing projectiles')
        return None
    if f == 'a_spawnitemex' or f == 'a_spawnitem':
        sn = sarg(a, 0)
        if not sn: return None
        fc = float(ev(sarg(a, 9, '0'), env, 0) or 0) if f == 'a_spawnitemex' else 0
        if fc > 0 and random.randint(0, 255) < fc: return None
        if is_monster(sn) or (is_spawner(sn) and spawner_is_monster(sn)):
            summon(res, sn, 1, t, children); res.tags.add('summons'); return None
        pi = proj_info(sn)
        if pi and (pi['dm'] > 0 or pi['expl'][0] > 0 or pi['flight'] or pi['kids']) and flag(sn, 'MISSILE') is not False:
            if f == 'a_spawnitem': return None
            xv = float(ev(sarg(a, 4, '0'), env, 0) or 0); yv = float(ev(sarg(a, 5, '0'), env, 0) or 0)
            zv = float(ev(sarg(a, 6, '0'), env, 0) or 0)
            fls = sarg(a, 8, '') or ''
            hs = math.hypot(xv, yv)
            if hs < 0.5 and not pi['seek']:
                # stationary hazard spawned at the monster: hits only in contact
                if d < 64: add_dmg(res, pi['name'] + '(hazard)', pi['dm'] * 0.5 + pi['expl'][0] * 0.5)
                return None
            base = math.degrees(math.atan2(yv, xv)) if hs > 0 else 0
            samples = [(float(ev(sarg(a, 7, '0'), env, 0) or 0) + base) for _ in range(24)]
            if 'ABSOLUTEANGLE' in fls.upper(): samples = [random.uniform(-180, 180) for _ in samples]
            pitch = abs(math.degrees(math.atan2(zv, hs))) if hs > 0 else 0
            e, p = proj_expect(pi, d, samples, pitch, since, speed_override=hs if hs > 0 else None)
            add_dmg(res, pi['name'] + '(ex)', e); res.attacks += 1
            if pi['dtype'] in ('ice', 'fire'): res.tags.add(pi['dtype'] + ' damage')
            if pi['seek']: res.tags.add('homing projectiles')
        else:
            # non-damaging, non-monster object: may itself summon (portal) -- one level
            if spawns_monsters(sn):
                for mc, k in spawns_monsters(sn).items(): summon(res, mc, k, t, children)
                res.tags.add('summons (via ' + sn + ')')
        return None
    if f == 'a_custombulletattack':
        sxy = float(ev(sarg(a, 0, '0'), env, 0) or 0); sz = float(ev(sarg(a, 1, '0'), env, 0) or 0)
        nb = float(ev(sarg(a, 2, '1'), env, 1) or 1); dpb = mean_expr(sarg(a, 3, '0'), 30)
        fls = sarg(a, 6, '') or ''; rng = float(ev(sarg(a, 5, '0'), env, 0) or 0)
        if rng > 0 and d > rng: return None
        mult = 1 if 'NORANDOM' in fls.upper() else 2
        ax = math.degrees(math.atan2(PLAYER_R, d)); az = math.degrees(math.atan2(PLAYER_HALF_H, d))
        if 'EXPLICITANGLE' in fls.upper(): px = 1.0 if abs(sxy) <= ax else 0.0; pz = 1.0 if abs(sz) <= az else 0.0
        else: px = tri_p(ax, abs(sxy)); pz = tri_p(az, abs(sz))
        pdodge = 1.0
        if 'AIMFACING' in fls.upper(): pdodge = p_lat(0, PLAYER_R, V_DODGE * max(0, since - T_REACT))
        add_dmg(res, 'bullets', nb * dpb * mult * px * pz * pdodge); res.attacks += 1; res.tags.add('hitscan')
        return None
    if f == 'a_customrailgun':
        dm = mean_expr(sarg(a, 0, '0'), 30); aim = int(ev(sarg(a, 5, '0'), env, 0) or 0)
        sxy = float(ev(sarg(a, 8, '0'), env, 0) or 0); sz = float(ev(sarg(a, 9, '0'), env, 0) or 0)
        rng = float(ev(sarg(a, 10, '0'), env, 0) or 0)
        if rng > 0 and d > rng: return None
        ax = math.degrees(math.atan2(PLAYER_R, d)); az = math.degrees(math.atan2(PLAYER_HALF_H, d))
        p = tri_p(ax, sxy) * tri_p(az, sz)
        if aim == 0: p *= p_lat(0, PLAYER_R, V_DODGE * max(0, since - T_REACT))
        add_dmg(res, 'railgun', dm * p); res.attacks += 1; res.tags.add('railgun')
        return None
    if f in ('a_custommeleeattack', 'a_meleeattack', 'a_skelfist', 'a_sargattack') or (f in NATIVE_MELEE and d < mr + PLAYER_R):
        if d >= mr + PLAYER_R + 8: return None
        if f == 'a_custommeleeattack': dm = mean_expr(sarg(a, 0, '0'), 30)
        elif f == 'a_meleeattack': dm = float(ev(prop(n, 'meleedamage', '0')[0]) or 0) * 4.5
        else: dm = NATIVE_MELEE.get(f, 0)
        add_dmg(res, 'melee', dm * 0.8); res.attacks += 1
        return None
    if f in NATIVE_PROJ:
        pi = proj_info(NATIVE_PROJ[f]); e, p = proj_expect(pi, d, [0.0])
        add_dmg(res, f, e); res.attacks += 1
        if pi and pi['seek']: res.tags.add('homing projectiles')
        return None
    if f in ('a_fatattack1', 'a_fatattack2', 'a_fatattack3'):
        pn = 'FatShot'; pi = proj_info(pn)
        angs = {'a_fatattack1': [0, 11.25], 'a_fatattack2': [0, -11.25], 'a_fatattack3': [-5.625, 5.625]}[f]
        for an in angs:
            e, p = proj_expect(pi, d, [an]); add_dmg(res, 'FatShot', e)
        res.attacks += 1; return None
    if f in ('a_posattack', 'a_cposattack') or f.startswith('a_sposattack'):
        k = 3 if f.startswith('a_sposattack') else 1
        ax = math.degrees(math.atan2(PLAYER_R, d))
        add_dmg(res, 'bullets', k * 9 * tri_p(ax, 22.4)); res.attacks += 1; res.tags.add('hitscan'); return None
    if f == 'a_viletarget':
        res.tags.add('vile fire (hitscan-like)'); return None
    if f == 'a_vileattack':
        idm = float(ev(sarg(a, 1, '20'), env, 20) or 20); bdm = float(ev(sarg(a, 2, '70'), env, 70) or 70)
        add_dmg(res, 'vileattack', (idm + bdm * 0.8) * 0.85); res.attacks += 1; return None
    if f in ('a_painattack', 'a_dualpainattack'):
        sn = sarg(a, 0, 'LostSoul') or 'LostSoul'
        summon(res, sn, 2 if f == 'a_dualpainattack' else 1, t, children); res.tags.add('summons'); return None
    if f == 'a_explode':
        ed = mean_expr(sarg(a, 0, '-1'), 20); er = mean_expr(sarg(a, 1, '-1'), 20)
        if ed < 0: ed = 128
        if er < 0: er = 128
        if d < er: add_dmg(res, 'self-explode', ed * (1 - d / er))
        return None
    if f == 'a_customcomboattack':
        if d < mr + PLAYER_R: add_dmg(res, 'melee', mean_expr(sarg(a, 2, '0'), 30) * 0.8)
        else:
            pi = proj_info(sarg(a, 0)); e, p = proj_expect(pi, d, [0.0]); add_dmg(res, 'combo', e)
        res.attacks += 1; return None
    if f.endswith('.firelead'):
        pn = sarg(a, 1); pi = proj_info(pn)
        if pi: e, p = proj_expect(pi, d, [0.0], lead=True); add_dmg(res, pi['name'] + '(lead)', e); res.attacks += 1
        return None
    return None

def advance_rel(cn, idx, k):
    fr = cls(cn)['frames']; j = idx; cnt = 0
    while j < len(fr):
        j += 1
        if j >= len(fr): return None
        if 'ctl' in fr[j]: continue
        cnt += 1
        if cnt == k: return (cn, j)
    return None

MA = {}
def maxamt(item):
    if item in MA: return MA[item]
    c = cls(item)
    if not c: MA[item] = 1e9; return MA[item]
    v = prop(item, 'inventory.maxamount')[0]
    MA[item] = float(ev(v, None, 1) or 1) if v else 1.0
    return MA[item]

SPM = {}
def spawner_is_monster(sn):
    c = cls(sn)
    for ch in chain(sn):
        for nm, p, w, ln in ch['dropitems']:
            if is_monster(nm) or (is_spawner(nm) and nm.lower() != sn.lower()): return True
    return False

def spawns_monsters(sn, depth=0):
    """non-monster helper actor (portal, orb): expected monsters spawned over its life (first pass of its states)"""
    k = sn.lower()
    if k in SPM: return SPM[k]
    SPM[k] = {}
    if depth > 2 or not cls(sn): return {}
    out = {}
    r = resolve_label(sn, 'spawn'); seen = {}; steps = 0
    while r and steps < 600:
        steps += 1
        seen[r] = seen.get(r, 0) + 1
        if seen[r] > 6: break
        f = cls(r[0])['frames'][r[1]]
        for fn, a in calls(f.get('act', '')):
            fl = fn.lower()
            if fl in ('a_spawnitemex', 'a_spawnitem', 'a_custommissile', 'a_spawnprojectile'):
                s2 = sarg(a, 0)
                if s2 and (is_monster(s2) or (is_spawner(s2) and spawner_is_monster(s2))):
                    out[s2] = out.get(s2, 0) + 1
        r = static_goto(r[0], r[1])
    SPM[k] = out
    return out

def spawner_expand(sn):
    """RandomSpawner -> {class: prob}"""
    items = []
    for ch in chain(sn):
        if ch['dropitems']: items = ch['dropitems']; break
    tot = sum(max(1, w) for nm, p, w, ln in items if nm.lower() != 'none')
    return {nm: max(1, w) / tot for nm, p, w, ln in items if nm.lower() != 'none'} if tot else {}

def simulate(n, d, runs=RUNS, seed=1):
    random.seed(hash((n.lower(), d, seed)) & 0xffffffff)
    res = Res()
    for i in range(runs):
        run(n, d, res=res)
    return res
