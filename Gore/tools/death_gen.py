#!/usr/bin/env python3
"""death_gen.py -- RSQ Gore PHASE 4: Brutal Doom's and XMVE's death-group launchers become RECIPES, and BD's wall
blood missiles become WALL CARDS (design/GORE_SYSTEM_DESIGN.md 2.3 rows "Wall blood" and "Death groups", section 4
rows "WallRedBlood family" and "GoreGroups.dec launchers", section 7 phase 4).

    python -I Gore/tools/death_gen.py <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>

Reads both pk3s straight from the zips (read-only) and Gore's own generated files (the takeover table and the phase
1-3 cards, to know which classes those phases take over). Writes:

    Gore/zscript/rsqgo/death_cards.zs    one class per launcher (RSQGO_D_<BD class>) and per wall missile
                                         (RSQGO_W_<BD class>), and RSQGO_Deaths.BuildCards(): every recipe and card
    Gore/generated/death_summary.txt     per class: what each entry becomes, actors per death before and after, and
                                         every class left to BD with the reason

A RECIPE is a launcher's Spawn sequence read entry by entry, exactly as BD's DECORATE writes it: every
A_CustomMissile / A_SpawnProjectile / A_SpawnItem / A_SpawnItemEx with its arguments as written (constants, random()
and frandom() ranges, so the run draws BD's own numbers in BD's order from the same RNG), the tic it runs on (the
engine's first-state rule: a spawned actor's first state runs its action only with NoDelay, cards.explore), the
sounds, A_FaceTarget, and BD's blood-intensity script (LowBlood / LotsOfBlood / AbsurdBlood entered on the tic the
script acts, cards.hit_card's timing). Each entry is ROUTED by what it spawns (deaths.zs):

    liquid   phase 1's Process (flying blood, mist, jets, SuperGore spawners, liquid checks): particles, no actor
    ceil     phase 2's launcher trace (CeilBloodLauncher*): the ceiling spot placed where BD's would land
    wall     a wall card (SuperWallRedBlood ...): one trace along BD's flight, BD's decal where it meets a wall
    recipe   a painter (RedBloodCircularWallPainter ...) whose own entries are all traces: run inline, no actor
    chunk    a real actor through the takeover (meat, guts, limbs: phase 3's cards); rsqgo_amount applies
    actor    a real actor through the takeover (floor spots, hit bloods, nested launchers, classes no phase takes)

A WALL CARD is a wall missile: its Speed, gravity, how many moves it makes (dry and under water) and its Decal.

Deterministic: classes in table order (category, then name), entries in state order. Never hand-edit the outputs.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import decorate  # noqa: E402
import cards  # noqa: E402

GORE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TABLE = os.path.join(GORE, 'generated', 'takeover_table.txt')
OUT = {'zscript': os.path.join('zscript', 'rsqgo', 'death_cards.zs'),
       'summary': os.path.join('generated', 'death_summary.txt')}

# routes (deaths.zs RSQGO_Deaths DR_*), modes (DM_*), groups (DG_*), argument kinds (DA_*)
DR = ('actor', 'chunk', 'liquid', 'ceil', 'wall', 'recipe', 'sound', 'face')
R_ACTOR, R_CHUNK, R_LIQUID, R_CEIL, R_WALL, R_RECIPE, R_SOUND, R_FACE = range(8)
M_MISSILE, M_ITEM, M_ITEMEX, M_NONE = range(4)
G_MAIN, G_LOW, G_LOTS, G_ABSURD, G_ANIMU = range(5)
GROUP_NAMES = ('main', 'low', 'lots', 'absurd', 'animu')
LEVEL_LABELS = ((G_LOW, 'LowBlood'), (G_LOTS, 'LotsOfBlood'), (G_ABSURD, 'AbsurdBlood'))
NARG = 9
WALL_LIFE_CAP = 350             # a looping wall missile (WallRedBlood: gravity 0.7) flies at most this many moves
CMF_AIMMODE, CMF_ABSOLUTEANGLE, CMF_BADPITCH = 3, 128, 256

CONSTS = {
    'cmf_aimoffset': 1, 'cmf_aimdirection': 2, 'cmf_trackowner': 4, 'cmf_checktargetdead': 8, 'cmf_absolutepitch': 16,
    'cmf_offsetpitch': 32, 'cmf_savepitch': 64, 'cmf_absoluteangle': 128,
    'sxf_transfertranslation': 1, 'sxf_absoluteposition': 2, 'sxf_absoluteangle': 4, 'sxf_absolutemomentum': 8,
    'sxf_absolutevelocity': 8, 'sxf_setmaster': 16, 'sxf_nocheckposition': 32, 'sxf_telefrag': 64, 'sxf_clientside': 128,
    'sxf_transferambushflag': 256, 'sxf_transferpitch': 512, 'sxf_transferpointers': 1024, 'sxf_usebloodcolor': 2048,
    'sxf_clearcallertid': 4096, 'sxf_multiplyspeed': 8192, 'sxf_transferscale': 16384, 'sxf_transferspecial': 32768,
    'sxf_clearcallerspecial': 65536, 'sxf_transferstencilcol': 131072, 'sxf_transferalpha': 262144,
    'sxf_transferrenderstyle': 524288, 'sxf_settarget': 1048576, 'sxf_settracer': 2097152, 'sxf_nopointers': 4194304,
    'sxf_originator': 8388608, 'sxf_transferroll': 33554432,
    'chan_auto': 0, 'chan_weapon': 1, 'chan_voice': 2, 'chan_item': 3, 'chan_body': 4,
    'attn_none': 0, 'attn_norm': 1, 'attn_idle': 1.001, 'attn_static': 3, 'true': 1, 'false': 0,
}
SPAWNERS = {'a_custommissile': M_MISSILE, 'a_spawnprojectile': M_MISSILE, 'a_spawnitem': M_ITEM, 'a_spawnitemex': M_ITEMEX}
# Arguments after the class: (count kept, defaults). A_SpawnItem's useammo / transfer_translation and A_SpawnItemEx's
# tid are refused unless they hold the default (the run calls the engine function with the defaults).
ARG_DEFAULTS = {M_MISSILE: ['32', '0', '0', '0', '0'], M_ITEM: ['0', '0'],
                M_ITEMEX: ['0', '0', '0', '0', '0', '0', '0', '0', '0']}
LIQUID_CATS = ('flying+trail', 'mist+jet', 'liquid check')
CHUNK_CATS = ('meat+guts', 'limb')


# ------------------------------------------------------------------ inputs
def read_table(path=TABLE):
    rows, order = {}, []
    for ln in open(path, encoding='utf-8'):
        if ln.startswith('#') or ln.startswith('class\t') or not ln.strip():
            continue
        f = ln.rstrip('\n').split('\t')
        rows[f[0].lower()] = {'name': f[0], 'cat': f[1], 'phase': f[2], 'owner': f[3], 'source': f[5]}
        order.append(f[0].lower())
    return rows, order


def gen_classes(root, fname, prefix):
    """Lower BD names that a phase's generated file gives a class (class <prefix><BD name>)."""
    p = os.path.join(root, 'zscript', 'rsqgo', fname)
    try:
        t = open(p, encoding='utf-8').read()
    except OSError:
        return set()
    return {m.lower() for m in re.findall(r'^class\s+' + prefix + r'(\w+)\s*:', t, re.M)}


def pain_sound(world, key):
    for k in world.chain(key):
        a = world.cls[k]
        body = getattr(a, '_rsq_body', None)
        if body is None:
            continue
        m = re.search(r'^\s*painsound\s+"([^"]*)"', body, re.I | re.M)
        if m:
            return m.group(1)
    return ''


# ------------------------------------------------------------------ arguments
NUM_RE = re.compile(r'^[-+]?(?:\d+\.?\d*|\.\d+)$')
RAND_RE = re.compile(r'^(f?random)\s*\(\s*([-+]?[\d.]+)\s*,\s*([-+]?[\d.]+)\s*\)$', re.I)


def parse_arg(expr):
    """('c', v, v) | ('r', lo, hi) | ('f', lo, hi), or None (an expression the run cannot evaluate: the class is left)."""
    e = expr.strip()
    if NUM_RE.match(e):
        v = float(e)
        return ('c', v, v)
    m = RAND_RE.match(e)
    if m:
        a, b = float(m.group(2)), float(m.group(3))
        if m.group(1).lower() == 'random':
            # DECORATE's random() is integer: its arguments are converted to int (codegen FxRandom), drawn from
            # pr_exrandom (thingdef_exp.cpp: no [name]); ZScript's unnamed random() is the same RNG and the same call.
            return ('r', float(int(a)), float(int(b)))
        return ('f', a, b)
    if re.match(r'^[\w|\s]+$', e):
        v = 0
        for part in e.split('|'):
            p = part.strip().lower()
            if p in CONSTS:
                v |= int(CONSTS[p]) if isinstance(CONSTS[p], int) else 0
                if not isinstance(CONSTS[p], int):
                    return ('c', CONSTS[p], CONSTS[p])
            elif re.match(r'^\d+$', p):
                v |= int(p)
            else:
                return None
        return ('c', float(v), float(v))
    return None


def fmt_num(v):
    if float(v) == int(v):
        return str(int(v))
    return ('%.4f' % v).rstrip('0').rstrip('.')


def fmt_args(args):
    out = []
    for k, lo, hi in args:
        out.append(fmt_num(lo) if k == 'c' else '%s%s:%s' % (k, fmt_num(lo), fmt_num(hi)))
    return ' '.join(out)


# ------------------------------------------------------------------ reading a launcher
class Refused(Exception):
    pass


def top_calls(action):
    """[(name, [args])] for the TOP-LEVEL calls of a state's action (cards.calls_in also lists the random() calls
    nested in the arguments)."""
    out, i = [], 0
    while True:
        m = cards.CALL_RE.search(action, i)
        if not m:
            break
        j = decorate.match_brace(action, m.end() - 1, '(', ')')
        out.append((m.group(1), cards.split_args(action[m.end():j])))
        i = j + 1
    if not out and action and re.match(r'^[A-Za-z_]\w*$', action.strip()):
        out.append((action.strip(), []))
    return out


def single_path(world, key, label, ctx, loops=False):
    paths = cards.explore(world, key, label, ctx)
    if not paths:
        raise Refused('no %s state' % label)
    if len(paths) != 1:
        raise Refused('%s has %d random branches' % (label, len(paths)))
    p = paths[0]
    if loops and p['end'][0] == 'loop':
        return p
    if p['end'][0] != 'stop':
        raise Refused('%s does not end (%s)' % (label, p['end'][0]))
    return p


def path_actions(world, key, path, label):
    """[(tic, kind, payload)] in state order. kind: 'spawn' (mode, class, [args]), 'sound' (name, slot, vol, atten),
    'face', 'pain', 'acs' (script). Raises Refused on anything a recipe cannot reproduce."""
    out = []
    for (d, i, t, tics, jumped, gate, noact) in path['steps']:
        if jumped:
            raise Refused('%s jumps' % label)
        if noact:
            continue
        s = world.cls[d].states.S[i]
        for name, args in top_calls(s['action']):
            nl = name.lower()
            if nl in SPAWNERS:
                mode = SPAWNERS[nl]
                if not args or not args[0].strip().startswith('"'):
                    raise Refused('%s: %s without a quoted class' % (label, name))
                cls = cards.unq(args[0])
                rest = args[1:]
                dflt = ARG_DEFAULTS[mode]
                if mode == M_MISSILE and len(rest) > 6:
                    raise Refused('%s: %s with %d arguments' % (label, name, len(args)))
                if mode == M_MISSILE and len(rest) == 6 and rest[5].strip().lower() not in ('aaptr_target', '0x2', '2'):
                    raise Refused('%s: %s with a pointer argument' % (label, name))
                if mode == M_ITEM and len(rest) > 2:
                    extra = [x.strip().lower() for x in rest[2:]]
                    if extra[:1] not in (['true'], ['1']) or any(x not in ('false', '0') for x in extra[1:]):
                        raise Refused('%s: A_SpawnItem with useammo / translation arguments' % label)
                if mode == M_ITEMEX and len(rest) > 9 and any(x.strip() not in ('0', '') for x in rest[9:]):
                    raise Refused('%s: A_SpawnItemEx with a tid' % label)
                vals = []
                for j, dv in enumerate(dflt):
                    a = parse_arg(rest[j] if j < len(rest) and rest[j].strip() != '' else dv)
                    if a is None:
                        raise Refused('%s: %s argument %r is not a number or a random range' % (label, name, rest[j]))
                    vals.append(a)
                if mode == M_MISSILE and nl == 'a_custommissile':
                    # compatibility.zs A_CustomMissile: A_SpawnProjectile(..., flags | CMF_BADPITCH, ...)
                    if vals[3][0] != 'c':
                        raise Refused('%s: random flags' % label)
                    vals[3] = ('c', float(int(vals[3][1]) | CMF_BADPITCH), float(int(vals[3][1]) | CMF_BADPITCH))
                if mode in (M_MISSILE, M_ITEMEX) and vals[3 if mode == M_MISSILE else 7][0] != 'c':
                    raise Refused('%s: random flags' % label)
                while len(vals) < NARG:
                    vals.append(('c', 0.0, 0.0))
                out.append((t, 'spawn', (mode, cls, vals)))
            elif nl in ('a_playsound', 'a_startsound'):
                if not args:
                    raise Refused('%s: %s without a sound' % (label, name))
                snd = cards.unq(args[0])
                if nl == 'a_playsound':
                    a = [parse_arg(x) for x in (args[1:5] + ['chan_body', '1', 'false', 'attn_norm'][len(args) - 1:])]
                    if any(x is None or x[0] != 'c' for x in a):
                        raise Refused('%s: A_PlaySound arguments' % label)
                    slot, vol, loop, att = int(a[0][1]), a[1][1], int(a[2][1]), a[3][1]
                    flags = (slot & ~7) | ((1 | 16) if loop else 0)     # s_doomsound.cpp A_PlaySound
                    slot &= 7
                else:
                    a = [parse_arg(x) for x in (args[1:5] + ['chan_body', '0', '1', 'attn_norm'][len(args) - 1:])]
                    if any(x is None or x[0] != 'c' for x in a):
                        raise Refused('%s: A_StartSound arguments' % label)
                    slot, flags, vol, att = int(a[0][1]), int(a[1][1]), a[2][1], a[3][1]
                vals = [('c', float(slot), float(slot)), ('c', float(flags), float(flags)), ('c', vol, vol), ('c', att, att)]
                while len(vals) < NARG:
                    vals.append(('c', 0.0, 0.0))
                out.append((t, 'sound', (snd, vals)))
            elif nl == 'a_facetarget':
                if args:
                    raise Refused('%s: A_FaceTarget with arguments' % label)
                out.append((t, 'face', None))
            elif nl == 'a_pain':
                ps = pain_sound(world, key)
                if ps:
                    raise Refused('%s: A_Pain with a PainSound (%s)' % (label, ps))
                # no PainSound: A_Pain plays nothing for a non-player (p_enemy.cpp A_Pain)
            elif nl == 'acs_namedexecutealways' and args and cards.unq(args[0]).lower() == 'bd_checkbloodintensity':
                out.append((t, 'acs', 'BD_CheckBloodIntensity'))
            else:
                raise Refused('%s: %s is not something a recipe runs' % (label, name))
    return out


def loop_water_exit(world, path):
    """A looping path whose loop start holds a water jump that is taken under water (cards.water_taken)."""
    end = path['end']
    t_loop = end[1] - end[2]
    for (d, i, t, tics, jumped, gate, noact) in path['steps']:
        if t != t_loop:
            continue
        for name, args in top_calls(world.cls[d].states.S[i]['action']):
            if name.lower() == 'a_jumpif' and args and cards.water_taken(args[0], True):
                return True
    return False


class Gen:
    def __init__(self, bd, xm, root=GORE):
        self.bd, self.xm, self.root = bd, xm, root
        self.world = decorate.World([(bd, 'BD'), (xm, 'XMVE')])
        self._bodies([(bd, 'BD'), (xm, 'XMVE')])
        self.rows, self.order = read_table(os.path.join(GORE, 'generated', 'takeover_table.txt'))
        self.p1 = gen_classes(GORE, 'cards.zs', 'RSQGO_K_')
        self.p2 = gen_classes(GORE, 'residue_cards.zs', 'RSQGO_R_')
        self.p3 = gen_classes(GORE, 'chunk_cards.zs', 'RSQGO_G_')
        # DECORATE `replaces` (the engine follows the chain after our handler answers: info.cpp GetReplacement)
        self.repl = {}
        for k in self.world.order:
            a = self.world.cls[k]
            if a.replaces:
                self.repl[a.replaces.lower()] = k
        self.walls, self.wall_idx, self.recipes, self.rec_idx, self.left = [], {}, [], {}, []

    def _bodies(self, packs):
        """Keep each class's property text (PainSound is not one of decorate.PROP_KEYS)."""
        for path, short in packs:
            pk = decorate.Pk3(path, short)
            for lname in pk.names:
                if not (lname.endswith('.dec') or lname.endswith('.txt') or '/' not in lname):
                    continue
                try:
                    t = decorate.strip_comments(pk.read(lname))
                except Exception:
                    continue
                for m in re.finditer(r'(?im)^\s*actor\s+([\w.]+)[^{\n]*\{', t):
                    k = m.group(1).lower()
                    a = self.world.cls.get(k)
                    if a is None or getattr(a, '_rsq_body', None) is not None:
                        continue
                    if not a.source.endswith(pk.names[lname]):
                        continue
                    j = decorate.match_brace(t, m.end() - 1)
                    body = t[m.end():j]
                    si = re.search(r'(?i)\bstates\s*\{', body)
                    a._rsq_body = body[:si.start()] if si else body

    def eff(self, key):
        seen = set()
        while key in self.repl and key not in seen:
            seen.add(key)
            key = self.repl[key]
        return key

    def cat(self, key):
        r = self.rows.get(key)
        return r['cat'] if r else None

    # ---------------------------------------------------------------- wall cards
    def wall_card(self, key):
        w = self.world
        fl = w.flags(key)
        if not fl.get('missile'):
            raise Refused('not a missile')
        if fl.get('_bounce') or any(fl.get(f) for f in decorate.BOUNCE_FLAGS):
            raise Refused('bounces')
        dry = single_path(w, key, 'Spawn', cards.Ctx(water=False), loops=True)
        wet = single_path(w, key, 'Spawn', cards.Ctx(water=True), loops=True)
        for p, lb in ((dry, 'Spawn'), (wet, 'Spawn (under water)')):
            if path_actions(w, key, p, lb):
                raise Refused('%s does something besides flying' % lb)
        if w.find_label(key, 'Death') is not None:
            dp = cards.explore(w, key, 'Death', cards.Ctx())
            for p in dp:
                try:
                    acts = path_actions(w, key, p, 'Death')
                except Refused:
                    acts = True
                if acts:
                    raise Refused('its Death spawns and plays things where it lands (left to BD)')
        decal = w.pval(key, 'decal', '')
        if not decal:
            raise Refused('no Decal')
        speed = cards.fnum(w.pval(key, 'speed'), 0.0)
        grav = 0.0 if fl.get('nogravity') else cards.fnum(w.pval(key, 'gravity'), 1.0)

        def moves(p):
            # removed in its tick E, after moving in that tick (AActor::Tick moves before it counts the state down);
            # a looping one (WallRedBlood) flies until it meets something, at most WALL_LIFE_CAP moves
            if p['end'][0] == 'loop':
                if p is wet and loop_water_exit(w, p):
                    # under water the loop comes back to its A_JumpIf(waterlevel > 1, "Splash") (no longer the first
                    # state, so it runs) and the missile vanishes in that tick: no decal
                    return p['end'][1] + 1
                return WALL_LIFE_CAP
            return p['end'][1] + 1

        return {'key': key, 'name': w.cls[key].name, 'speed': speed, 'grav': grav, 'decal': decal,
                'life': min(moves(dry), WALL_LIFE_CAP), 'lifewet': min(moves(wet), WALL_LIFE_CAP),
                'radius': cards.fnum(w.pval(key, 'radius'), 20.0), 'height': cards.fnum(w.pval(key, 'height'), 16.0)}

    # ---------------------------------------------------------------- recipes
    def read_recipe(self, key):
        w = self.world
        main = single_path(w, key, 'Spawn', cards.Ctx(water=False))
        wet = single_path(w, key, 'Spawn', cards.Ctx(water=True))
        if [s[:3] for s in main['steps']] != [s[:3] for s in wet['steps']]:
            raise Refused('its Spawn depends on water')
        acts = path_actions(w, key, main, 'Spawn')
        end = main['end'][1]
        acs = [a for a in acts if a[1] == 'acs']
        if len(acs) > 1:
            raise Refused('calls the intensity script twice')
        entries = [(t, G_MAIN, k, p) for t, k, p in acts if k != 'acs']
        acs_at = -1
        ends = {G_MAIN: max([e[0] for e in entries] or [0])}
        if acs:
            t_acs = acs[0][0]
            at = t_acs + (2 if t_acs == 0 else 1)      # cards.hit_card: the script acts after Delay(1)
            if end > at:                                # BD's launcher is still there when it acts
                acs_at = at
                absurd_plain = None
                for g, label in LEVEL_LABELS:
                    if w.find_label(key, label) is None:
                        continue
                    lp = single_path(w, key, label, cards.Ctx())
                    la = path_actions(w, key, lp, label)
                    if any(x[1] == 'acs' for x in la):
                        raise Refused('%s calls a script' % label)
                    entries += [(acs_at + t, g, k, p) for t, k, p in la]
                    if g == G_ABSURD:
                        absurd_plain = [s[:3] for s in lp['steps']]
                        # level 5 gives AnimuGore to the launcher first (Options.acs): a different path if it checks it
                        ap = single_path(w, key, label, cards.Ctx(take=('AnimuGore',)))
                        if [s[:3] for s in ap['steps']] != absurd_plain:
                            entries += [(acs_at + t, G_ANIMU, k, p) for t, k, p in path_actions(w, key, ap, label)]
                    gl = [e[0] for e in entries if e[1] == g]
                    ends[g] = max([e[0] for e in entries if e[1] == G_MAIN and e[0] <= acs_at] + gl + [acs_at])
                if any(e[1] == G_ANIMU for e in entries):
                    ends[G_ANIMU] = max([e[0] for e in entries if e[1] == G_MAIN and e[0] <= acs_at] +
                                        [e[0] for e in entries if e[1] == G_ANIMU] + [acs_at])
        fl = w.flags(key)
        return {'key': key, 'name': w.cls[key].name, 'entries': entries, 'acs_at': acs_at, 'ends': ends,
                'end_bd': end, 'missile': bool(fl.get('missile')), 'nograv': bool(fl.get('nogravity')),
                'speed': cards.fnum(w.pval(key, 'speed'), 0.0), 'radius': cards.fnum(w.pval(key, 'radius'), 20.0),
                'height': cards.fnum(w.pval(key, 'height'), 16.0), 'cat': self.cat(key)}

    def inline_ok(self, rec):
        """A painter whose entries are all traces (no actor, no sound, no script, all on its first tic)."""
        if rec['acs_at'] >= 0:
            return False
        for t, g, k, p in rec['entries']:
            if t != 0 or k != 'spawn':
                return False
            if p[0] == M_MISSILE and int(p[2][3][1]) & CMF_AIMMODE != 2:
                return False
            if self.eff(p[1].lower()) not in self.wall_idx:
                return False
        return True

    def route(self, mode, flags, cls):
        key = cls.lower()
        ek = self.eff(key)
        aim2 = mode != M_MISSILE or (flags & CMF_AIMMODE) == 2
        cat = self.cat(ek)
        if ek in self.wall_idx and aim2:
            return R_WALL, self.wall_idx[ek], ek
        if ek in self.rec_idx and self.recipes[self.rec_idx[ek]]['inline'] and aim2:
            return R_RECIPE, self.rec_idx[ek], ek
        if cat == 'ceiling' and 'launcher' in ek and ek in self.p2 and aim2:
            return R_CEIL, -1, ek
        if cat in LIQUID_CATS and ek in self.p1 and aim2:
            return R_LIQUID, -1, ek
        if cat in CHUNK_CATS:
            return R_CHUNK, -1, ek
        return R_ACTOR, -1, ek

    def run(self):
        w = self.world
        cand = [k for k in self.order if self.rows[k]['cat'] in ('wall', 'death group') and self.rows[k]['owner'] == 'gore']
        for k in cand:
            if k not in w.cls:
                self.left.append((self.rows[k]['name'], 'not in the packs'))
        cand = [k for k in cand if k in w.cls]
        # wall cards first (recipes route to them)
        for k in cand:
            if self.rows[k]['cat'] != 'wall':
                continue
            try:
                c = self.wall_card(k)
            except Refused:
                continue
            self.wall_idx[k] = len(self.walls)
            self.walls.append(c)
        # then recipes: every death group and every wall class that is not a wall card (painters, splinters)
        for k in cand:
            if k in self.wall_idx:
                continue
            try:
                r = self.read_recipe(k)
            except Refused as e:
                why = str(e)
                if self.rows[k]['cat'] == 'wall':
                    try:
                        self.wall_card(k)
                    except Refused as e2:
                        why = 'wall missile: %s; as a recipe: %s' % (e2, why)
                self.left.append((w.cls[k].name, why))
                continue
            if not any(e[2] == 'spawn' for e in r['entries']):
                why = 'spawns nothing (nothing to save)'
                if self.rows[k]['cat'] == 'wall':
                    try:
                        self.wall_card(k)
                    except Refused as e2:
                        why = 'wall missile: %s' % e2
                self.left.append((w.cls[k].name, why))
                continue
            r['inline'] = False
            self.rec_idx[k] = len(self.recipes)
            self.recipes.append(r)
        for r in self.recipes:
            r['inline'] = self.inline_ok(r)
        # route every entry
        for r in self.recipes:
            out = []
            for t, g, k, p in r['entries']:
                if k == 'spawn':
                    mode, cls, vals = p
                    flags = int(vals[3][1]) if mode == M_MISSILE else (int(vals[7][1]) if mode == M_ITEMEX else 0)
                    rt, ref, ek = self.route(mode, flags, cls)
                    out.append({'t': t, 'g': g, 'mode': mode, 'route': rt, 'ref': ref, 'cls': cls, 'eff': ek,
                                'args': vals})
                elif k == 'sound':
                    out.append({'t': t, 'g': g, 'mode': M_NONE, 'route': R_SOUND, 'ref': -1, 'cls': p[0], 'eff': '',
                                'args': p[1]})
                elif k == 'face':
                    out.append({'t': t, 'g': g, 'mode': M_NONE, 'route': R_FACE, 'ref': -1, 'cls': '', 'eff': '',
                                'args': [('c', 0.0, 0.0)] * NARG})
            # state order within a tic is kept (a stable sort by tic: FaceTarget before the spawns it turns)
            out.sort(key=lambda e: e['t'])
            r['out'] = out
        return self

    # ---------------------------------------------------------------- counts
    def counts(self, r, group=G_MAIN):
        """(BD actors, our actors, our one-tic actors, traces, liquid calls, ceiling launchers) for one death at a
        blood level whose group is `group` (G_MAIN: level 2, the default)."""
        bd = 1
        ours = 1
        quick = 0
        traces = liquid = ceil = 0
        for e in self.active(r, group):
            rt = e['route']
            if rt in (R_SOUND, R_FACE):
                continue
            bd += 1
            if rt == R_RECIPE:
                sub = self.recipes[e['ref']]
                bd += sum(1 for x in sub['out'] if x['route'] not in (R_SOUND, R_FACE))
                traces += sum(1 for x in sub['out'] if x['route'] == R_WALL)
            elif rt == R_WALL:
                traces += 1
            elif rt == R_LIQUID:
                liquid += 1
            elif rt == R_CEIL:
                ceil += 1
            elif rt == R_ACTOR and self.cat(e['eff']) in ('hit blood',) + LIQUID_CATS and e['eff'] in self.p1:
                quick += 1
            else:
                ours += 1
        return bd, ours, quick, traces, liquid, ceil

    def active(self, r, group):
        acs = r['acs_at']
        for e in r['out']:
            if e['g'] == G_MAIN and (group == G_MAIN or acs < 0 or e['t'] <= acs):
                yield e
            elif acs >= 0 and e['g'] == group:
                yield e


# ------------------------------------------------------------------ writing
def zstr(s):
    return '"%s"' % s.replace('\\', '\\\\').replace('"', '\\"')


def zf(v):
    return fmt_num(v)


def write_zscript(g, path, bdn):
    L = []
    L.append('// RSQ Gore phase 4 death recipes and wall cards -- GENERATED by Gore/tools/death_gen.py from %s and XMVE. '
             'Never hand-edit.' % bdn)
    L.append('//')
    L.append('// 1. One class per Brutal Doom / XMVE class this phase takes over (RSQGO_Manager.CheckReplacement, through')
    L.append('//    RSQGO_Deaths.Lookup): RSQGO_D_<launcher> runs that launcher\'s recipe, RSQGO_W_<wall missile> traces')
    L.append('//    that missile\'s flight. Each keeps BD\'s Speed (A_CustomMissile sets a spawned missile\'s velocity from the')
    L.append('//    SPAWNED class\'s Speed: p_actionfunctions.cpp A_SpawnProjectile) and BD\'s Radius (the advance of every')
    L.append('//    missile it spawns: P_CheckMissileSpawn(missile, shooter radius)).')
    L.append('// 2. RSQGO_Deaths.BuildCards(): every wall card, every recipe and its entries in BD\'s state order. An entry\'s')
    L.append('//    arguments are written as BD wrote them: a number, r<lo>:<hi> for random(lo, hi), f<lo>:<hi> for frandom.')
    L.append('//    Routes, modes and groups: deaths.zs (DR_*, DM_*, DG_*).')
    L.append('')
    for c in g.walls:
        L.append('class RSQGO_W_%s : RSQGO_WallRun { Default { RSQGO_WallRun.Wall %d; Speed %s; Radius %s; Height %s; } }' % (
            c['name'], g.wall_idx[c['key']], zf(c['speed']), zf(c['radius']), zf(c['height'])))
    for r in g.recipes:
        L.append('class RSQGO_D_%s : RSQGO_DeathRun { Default { RSQGO_DeathRun.Recipe %d; Speed %s; Radius %s; Height %s; } }' % (
            r['name'], g.rec_idx[r['key']], zf(r['speed']), zf(r['radius']), zf(r['height'])))
    L.append('')
    L.append('extend class RSQGO_Deaths')
    L.append('{')
    L.append('\tvoid BuildCards()')
    L.append('\t{')
    L.append('\t\t// Wall(BD class, our class, speed, gravity, moves dry, moves under water, decal)')
    for c in g.walls:
        L.append('\t\tWall(%s, "RSQGO_W_%s", %s, %s, %d, %d, %s);  // %d' % (
            zstr(c['name']), c['name'], zf(c['speed']), zf(c['grav']), c['life'], c['lifewet'], zstr(c['decal']),
            g.wall_idx[c['key']]))
    L.append('\t\t// Rec(BD class, our class, missile, nogravity, radius, script tic, end tic per group: main low lots '
             'absurd animu)')
    L.append('\t\t// E(tic, group, mode, route, ref, class to spawn, class routed, arguments)')
    for r in g.recipes:
        ends = r['ends']
        e5 = [ends.get(G_MAIN, 0)] + [ends.get(gg, -1) for gg in (G_LOW, G_LOTS, G_ABSURD, G_ANIMU)]
        L.append('\t\tRec(%s, "RSQGO_D_%s", %s, %s, %s, %d, "%s");  // %d%s' % (
            zstr(r['name']), r['name'], 'true' if r['missile'] else 'false', 'true' if r['nograv'] else 'false',
            zf(r['radius']), r['acs_at'], ' '.join(str(x) for x in e5), g.rec_idx[r['key']],
            ' (inline)' if r['inline'] else ''))
        for e in r['out']:
            L.append('\t\tE(%d, %d, %d, %d, %d, %s, %s, "%s");' % (
                e['t'], e['g'], e['mode'], e['route'], e['ref'], zstr(e['cls']),
                zstr(g.world.cls[e['eff']].name if e['eff'] in g.world.cls else e['eff']), fmt_args(e['args'])))
    L.append('\t}')
    L.append('}')
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(L) + '\n')


def write_summary(g, path, bdn):
    L = ['RSQ Gore phase 4 summary -- GENERATED by Gore/tools/death_gen.py. Never hand-edit.',
         'Packs: BD = %s, XMVE = %s' % (bdn, os.path.basename(g.xm)), '']
    rec_bd = rec_ours = 0
    nr = len(g.recipes)
    L.append('== Totals')
    L.append('  wall cards (RSQGO_W_*): %d    recipes (RSQGO_D_*): %d (%d inline painters)    left to BD: %d' % (
        len(g.walls), nr, sum(1 for r in g.recipes if r['inline']), len(g.left)))
    tot = [0] * len(DR)
    for r in g.recipes:
        for e in g.active(r, G_MAIN):
            tot[e['route']] += 1
    L.append('  entries at blood level 2 by route: ' + ', '.join('%s %d' % (DR[i], tot[i]) for i in range(len(DR))))
    L.append('')
    L.append('== Actors per death (blood level 2, the default; rsqgo_amount All)')
    L.append('  BD = the launcher + every actor its Spawn sequence spawns + what its inline painters spawn.')
    L.append('  ours = our recipe actor + real actors (chunks, floor spots, nested launchers, classes no phase takes);')
    L.append('  +q = one-tic actors (hit bloods, phase 1 classes reached by name: gone on their first tic);')
    L.append('  traces = wall decal traces; liquid = phase 1 Process calls; ceil = ceiling launcher traces (each may leave')
    L.append('  one parked, merged ceiling spot later).')
    L.append('  %-34s %5s %5s %4s %7s %7s %5s %s' % ('launcher', 'BD', 'ours', '+q', 'traces', 'liquid', 'ceil', 'over 30'))
    worst = []
    for r in g.recipes:
        if r['cat'] != 'death group':
            continue
        bd, ours, quick, tr, lq, ce = g.counts(r)
        rec_bd += bd
        rec_ours += ours
        worst.append((ours, r['name']))
        L.append('  %-34s %5d %5d %4d %7d %7d %5d %s' % (r['name'], bd, ours, quick, tr, lq, ce, 'OVER' if ours > 30 else ''))
    nd = sum(1 for r in g.recipes if r['cat'] == 'death group')
    if nd:
        L.append('  mean over %d death groups: BD %.1f, ours %.1f; most: %s' % (
            nd, rec_bd / nd, rec_ours / nd, ', '.join('%s %d' % (n, o) for o, n in sorted(worst, reverse=True)[:5])))
    L.append('')
    L.append('== Higher blood levels (BD_CheckBloodIntensity on the tic it acts): BD actors / ours, per level 0-1, 3, 4, 5')
    for r in g.recipes:
        if r['acs_at'] < 0:
            continue
        cells = []
        for gg in (G_LOW, G_LOTS, G_ABSURD, G_ANIMU):
            if gg == G_ANIMU and not any(e['g'] == G_ANIMU for e in r['out']):
                gg2 = G_ABSURD
            else:
                gg2 = gg
            bd, ours, quick, tr, lq, ce = g.counts(r, gg2)
            cells.append('%d/%d' % (bd, ours))
        L.append('  %-34s script acts t%d: %s' % (r['name'], r['acs_at'], '  '.join(cells)))
    L.append('')
    L.append('== Wall cards (BD class: speed, gravity, moves dry / under water, decal)')
    for c in g.walls:
        L.append('  %-30s speed %-4s gravity %-4s moves %d / %d  %s' % (
            c['name'], zf(c['speed']), zf(c['grav']), c['life'], c['lifewet'], c['decal']))
    L.append('')
    L.append('== Recipes (entries in BD order: tic, route, class; xN = N identical lines)')
    for r in g.recipes:
        L.append('  %s (%s%s; BD launcher ends t%d; script acts %s)' % (
            r['name'], r['cat'], ', inline painter' if r['inline'] else '', r['end_bd'],
            ('t%d' % r['acs_at']) if r['acs_at'] >= 0 else 'never'))
        prev, n = None, 0
        lines = []
        for e in r['out']:
            desc = (e['t'], GROUP_NAMES[e['g']], DR[e['route']], e['cls'], fmt_args(e['args']) if e['route'] != R_FACE else '')
            if desc == prev:
                n += 1
                continue
            if prev:
                lines.append((prev, n))
            prev, n = desc, 1
        if prev:
            lines.append((prev, n))
        for (t, gn, rt, cls, args), n in lines:
            extra = ''
            if rt == 'actor':
                c = g.cat(g.eff(cls.lower()))
                extra = ' [%s]' % (c or 'no phase')
            L.append('    t%-3d %-6s %-6s %s%s%s  (%s)' % (t, gn, rt, cls, ' x%d' % n if n > 1 else '', extra, args))
    L.append('')
    L.append('== Left to BD (%d)' % len(g.left))
    for n, why in sorted(g.left, key=lambda x: x[0].lower()):
        L.append('  %s: %s' % (n, why))
    L.append('')
    L.append('== Not matched exactly (named differences from BD)')
    for s in DIFFERENCES:
        L.append('  - ' + s)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(L) + '\n')


DIFFERENCES = (
    'Wall decals are painted on the tic the recipe runs, not 1-5 tics later when BD\'s missile reaches the wall, and '
    'by one trace along the flight\'s chord (gravity 0.1 over 5 moves bends it under a unit).',
    'A wall decal sits where the trace meets the wall (BD: the nearest point of the line to the missile, at its '
    'height); the same spot for a missile that hits the wall head on.',
    'Phase 1 entries (mist, flying blood, SuperGore spawners, liquid checks) are judged under water by the launcher\'s '
    'own waterlevel (as phase 1 judges a child by its parent\'s).',
    'At rsqgo_amount Some a recipe keeps every second chunk (design section 6), in recipe order; at None it spawns no '
    'chunk. The fly cap (rsqgo_fly_*) is checked before spawning instead of refusing the chunk on its first tic.',
    'A launcher with entries after its first tic stays one invisible actor until its last entry (BD: until its Stop).',
)


def write_all(bd, xm, root=GORE):
    g = Gen(bd, xm, root).run()
    bdn = os.path.basename(bd)
    P = {k: os.path.join(root, v) for k, v in OUT.items()}
    for p in P.values():
        os.makedirs(os.path.dirname(p), exist_ok=True)
    write_zscript(g, P['zscript'], bdn)
    write_summary(g, P['summary'], bdn)
    return g, P


def main(argv):
    if len(argv) != 3:
        print(__doc__.strip().split('\n\n')[1])
        return 2
    for p in argv[1:]:
        if not os.path.isfile(p):
            print('death_gen: no such pk3: ' + p)
            return 2
    g, P = write_all(argv[1], argv[2])
    print('wrote %s (%d wall cards, %d recipes, %d left to BD)' % (P['zscript'], len(g.walls), len(g.recipes), len(g.left)))
    print('wrote %s' % P['summary'])
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
