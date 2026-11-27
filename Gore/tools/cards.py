#!/usr/bin/env python3
"""cards.py -- RSQ Gore phase 1: Brutal Doom's liquid gore classes, simulated into emitter CARDS (used by gen_gore.py).

Phase 1 takes over the takeover table's "hit blood", "flying+trail", "mist+jet" and "liquid check" classes. For each
one this module walks the class's own DECORATE states (fall-through, every A_Jump branch with its odds) and writes down
what an actor of that class SHOWS and DOES, so RSQ Gore can show the same thing without the actor living:

  * what it shows: the frames (sprite, frame, tics), the scale and alpha as A_SetScale / A_FadeOut / A_FadeIn change them,
    per random branch (BD's Spawn1/Spawn2/Spawn3 scale picks, the 50/50 mirror), how long it lives;
  * what it spawns, when and how (A_CustomMissile / A_SpawnItemEx / A_SpawnItem with their random ranges);
  * what happens where it lands (Death with A_CheckFloor true or false: the floor spot it leaves, the splash frames,
    the sound) and under water (the waterlevel > 1 branch);
  * for a hit blood, every blood-level path (BD_CheckBloodIntensity: Low, level 2, LotsOfBlood, AbsurdBlood, AnimuGore),
    the saw branch, the screen-blood give and the low-damage state skip (P_SpawnBlood starts a blood 1-2 states in);
  * for a liquid checker, the liquid spot it leaves and which floor textures count (BD's SPLASH.acs, read from the pk3).

A class whose states do something phase 1 cannot reproduce (an ACS call, an inventory give that is not screen blood,
a spawn function it does not know) is LEFT to BD, with the reason written in generated/cards_summary.txt.

Particles take no translation and play an animation only through ANIMDEFS, and an ANIMDEFS animation is global to its
texture name. So every frame of every look gets its OWN texture, RSQGO_Lnnn_kk, a TEXTURES copy of BD's sprite patch on
a square canvas (the sprite's offset point at the centre), green / blue / alien gore from our own PNGs baked offline
through BD's translation (never Translation or Colormap in TEXTURES: see BAKE_DIR), and FlipX for a mirrored scale. No
RSQ Gore ANIMDEFS entry ever names a BD or XMVE texture (gore_lint.py fails if one does).

SIZE: a particle's quad is (canvas texels x BD's scale) map units wide, so the visible sprite inside it is exactly BD's
(texels x scale); the summary lists each card's quad width for checking against BD.

Deterministic: cards in table order, looks numbered in first-use order, floats printed with fixed precision.
"""
import math
import os
import re
import struct
import zipfile
import zlib

import decorate

PHASE1 = ('hit blood', 'flying+trail', 'mist+jet', 'liquid check')
CAT_CODE = {'hit blood': 0, 'flying+trail': 1, 'mist+jet': 2, 'liquid check': 3}
KIND_DROP, KIND_HIT, KIND_LIQUID = 0, 1, 2
LIFE_CAP = 350                  # a looping or parked look (PlayerFlyingBlood) lives at most this long before it lands
INVISIBLE = ('TNT1', 'NULL')
# Paths a child spawn belongs to (cards.zs RSQGO_Data P_*): what plays when.
# P_LEVEL2 is the hit blood's OWN path after the intensity script starts (its Spawn2 spawns and its LowBlood): it
# always runs, because BD's script acts only after it (hit_card). P_LOW is LowBlood entered again (levels 0 and 1, and
# the SlaughterCounter jump); P_LOTS / P_ABSURD / P_ANIMU the other levels' states, each through its LowBlood.
P_DROP, P_COMMON, P_LEVEL2, P_LOTS, P_ABSURD, P_ANIMU, P_WATER, P_SAW, P_FLOOR, P_WALL, P_LOW = range(11)
PATH_NAMES = ('drop', 'common', 'level2', 'lots', 'absurd', 'animu', 'water', 'saw', 'floor', 'wall', 'low')
# A hit blood's puff, one set of tracks per way BD's blood can reach its LowBlood frames (emit.zs RunHit picks one).
R_LEVEL2, R_LOW, R_LOTS, R_ABSURD, R_ANIMU, R_SLAUGHTER = range(6)
ROUTE_NAMES = ('level2', 'low', 'lots', 'absurd', 'animu', 'slaughter')
# Bounce bits (emit.zs B_*): which surfaces a missile bounces off instead of dying there.
B_WALLS, B_FLOORS, B_CEILINGS, B_AUTOOFF = 1, 2, 4, 8
BOUNCE_TYPES = {'none': 0, 'doom': 15, 'doomcompat': 15, 'hexen': 7, 'hexencompat': 7, 'heretic': 6,
                'hereticcompat': 6, 'grenade': 7, 'classic': 7}
M_MISSILE, M_ITEMEX, M_ITEM = 0, 1, 2
# BD's render style as is: the tracks are drawn by VisualThinkers through the engine's sprite path, like BD's actors.
STYLES = {'normal': 'STYLE_Normal', 'translucent': 'STYLE_Translucent', 'add': 'STYLE_Add', 'subtract': 'STYLE_Subtract',
          'shaded': 'STYLE_Shaded', 'stencil': 'STYLE_Stencil', 'addstencil': 'STYLE_AddStencil',
          'translucentstencil': 'STYLE_TranslucentStencil', 'fuzzy': 'STYLE_Translucent', 'optfuzzy': 'STYLE_Translucent',
          'soultrans': 'STYLE_Translucent', 'shadow': 'STYLE_Translucent', 'none': 'STYLE_None', 'addshaded': 'STYLE_AddShaded'}
# A textured particle is a square quad 2 x size x 2.5/7 across, shrunk by sqrt(pixelstretch 1.2)
# (QZD hw_sprites.cpp HWSprite::ProcessParticle). A sprite canvas of D texels at scale s is D x s map units, so
# size = D x s x K.
QUAD_K = 7.0 / 5.0 * math.sqrt(1.2)
# The model-drawn liquid spots stay BD's actors (BD's MODELDEF draws Waterbloodspot as a flat md3 on the water, which
# neither a particle nor a VisualThinker can draw): our liquid checker spawns them by name, as BD's checker does.
LEAVE_NAMES = re.compile(r'waterbloodspot$', re.I)


# ------------------------------------------------------------------ small parsers
def split_args(s):
    out, depth, cur, q = [], 0, [], False
    for ch in s:
        if ch == '"':
            q = not q
        if not q:
            if ch in '([':
                depth += 1
            elif ch in ')]':
                depth -= 1
            elif ch == ',' and depth == 0:
                out.append(''.join(cur).strip()); cur = []
                continue
        cur.append(ch)
    if ''.join(cur).strip():
        out.append(''.join(cur).strip())
    return out


CALL_RE = re.compile(r'\b([A-Za-z_]\w*)\s*\(')


def calls_in(action):
    """[(name, [args])] for every call in a state's action (a single call, or each call of a { } block)."""
    out = []
    for m in CALL_RE.finditer(action):
        j = decorate.match_brace(action, m.end() - 1, '(', ')')
        out.append((m.group(1), split_args(action[m.end():j])))
    if not out and action and re.match(r'^[A-Za-z_]\w*$', action.strip()):
        out.append((action.strip(), []))
    return out


def unq(s):
    return s.strip().strip('"')


def rng(expr, default=(0.0, 0.0)):
    """A DECORATE number or random range -> (lo, hi); None if it is an expression we do not evaluate."""
    if expr is None:
        return default
    e = expr.strip()
    if e == '':
        return default
    m = re.match(r'^f?random\s*(?:\[\w*\])?\s*\(\s*([-+]?[\d.]+)\s*,\s*([-+]?[\d.]+)\s*\)$', e, re.I)
    if m:
        a, b = float(m.group(1)), float(m.group(2))
        return (min(a, b), max(a, b))
    try:
        v = float(e)
        return (v, v)
    except ValueError:
        return None


def fnum(s, default):
    try:
        return float(s)
    except (TypeError, ValueError):
        return default


def eval_scale(expr, sx, sy):
    """A_SetScale argument: a number, or scalex/scaley plus or minus a number."""
    e = expr.replace(' ', '').lower()
    m = re.match(r'^(scalex|scaley)([-+][\d.]+)?$', e)
    if m:
        base = sx if m.group(1) == 'scalex' else sy
        return base + (float(m.group(2)) if m.group(2) else 0.0)
    return fnum(e, None)


# ------------------------------------------------------------------ sprites (sizes and offsets, both packs)
def read_sprite_info(data):
    """(w, h, xoff, yoff) of a PNG (IHDR + grAb) or a Doom patch, else None."""
    if data[:8] == b'\x89PNG\r\n\x1a\n':
        w, h = struct.unpack('>II', data[16:24])
        xo, yo = w // 2, h
        i = 8
        while i + 8 <= len(data):
            ln, typ = struct.unpack('>I4s', data[i:i + 8])
            if typ == b'grAb':
                xo, yo = struct.unpack('>ii', data[i + 8:i + 16])
                break
            if typ == b'IDAT':
                break
            i += 12 + ln
        return (w, h, xo, yo)
    if len(data) >= 8:
        w, h, xo, yo = struct.unpack('<hhhh', data[:8])
        if 0 < w <= 4096 and 0 < h <= 4096:
            return (w, h, xo, yo)
    return None


def decode_png(data):
    """(w, h, [(r, g, b, a)...]) for a non-interlaced PNG: 8-bit grey, RGB, grey+alpha, RGBA, or 1/2/4/8-bit palette
    or grey; tRNS honoured. Else None. The colour bake reads BD's frames with it (write_bakes)."""
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        return None
    i, idat, pal, trns = 8, b'', None, None
    w = h = depth = ct = None
    while i + 8 <= len(data):
        ln, typ = struct.unpack('>I4s', data[i:i + 8])
        body = data[i + 8:i + 8 + ln]
        if typ == b'IHDR':
            w, h, depth, ct, _, _, inter = struct.unpack('>IIBBBBB', body)
            if inter != 0 or depth not in (1, 2, 4, 8) or (depth != 8 and ct not in (0, 3)):
                return None
        elif typ == b'PLTE':
            pal = [tuple(body[k:k + 3]) for k in range(0, len(body), 3)]
        elif typ == b'tRNS':
            trns = body
        elif typ == b'IDAT':
            idat += body
        elif typ == b'IEND':
            break
        i += 12 + ln
    bpp = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}.get(ct)
    if bpp is None:
        return None
    raw = zlib.decompress(idat)
    stride = w * bpp if depth == 8 else (w * depth + 7) // 8
    prev = bytearray(stride)
    out = []
    pos = 0
    for _ in range(h):
        ft = raw[pos]; pos += 1
        line = bytearray(raw[pos:pos + stride]); pos += stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b = prev[x]
            c = prev[x - bpp] if x >= bpp else 0
            if ft == 1:
                line[x] = (line[x] + a) & 255
            elif ft == 2:
                line[x] = (line[x] + b) & 255
            elif ft == 3:
                line[x] = (line[x] + ((a + b) >> 1)) & 255
            elif ft == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 255
        if depth != 8:
            # unpack 1/2/4-bit samples (high bits first) into one byte each
            per, mask = 8 // depth, (1 << depth) - 1
            unpacked = bytearray(w)
            for x in range(w):
                unpacked[x] = (line[x // per] >> (8 - depth * (x % per + 1))) & mask
            prev = line
            for x in range(w):
                v = unpacked[x]
                if ct == 3:
                    r, g, b = pal[v] if pal and v < len(pal) else (0, 0, 0)
                    out.append((r, g, b, trns[v] if trns and v < len(trns) else 255))
                else:
                    gv = v * 255 // mask
                    out.append((gv, gv, gv, 255))
            continue
        for x in range(w):
            s = line[x * bpp:(x + 1) * bpp]
            if ct == 6:
                out.append(tuple(s))
            elif ct == 2:
                out.append((s[0], s[1], s[2], 255))
            elif ct == 3:
                r, g, b = pal[s[0]] if pal and s[0] < len(pal) else (0, 0, 0)
                out.append((r, g, b, trns[s[0]] if trns and s[0] < len(trns) else 255))
            elif ct == 0:
                out.append((s[0], s[0], s[0], 255))
            else:
                out.append((s[0], s[0], s[0], s[1]))
        prev = line
    return w, h, out


def load_sprites(packs):
    """NAME -> (w, h, xoff, yoff) for every lump under sprites/ in the packs; a later pack wins (load order)."""
    out = {}
    for path, _ in packs:
        z = zipfile.ZipFile(path)
        for n in sorted(z.namelist()):
            ln = n.replace('\\', '/').lower()
            if not ln.startswith('sprites/') or ln.endswith('/'):
                continue
            base = n.split('/')[-1].split('.')[0].upper()
            info = read_sprite_info(z.read(n)[:4096])
            if info:
                out[base] = info
    return out


def frame_lump(sprites, spr, fr):
    """(lump, flipped, info) for sprite spr frame fr: rotation 0, else rotation 1, else the second half of a pair."""
    for lump in (spr + fr + '0', spr + fr + '1'):
        if lump in sprites:
            return lump, False, sprites[lump]
    for lump, info in sorted(sprites.items()):
        if lump.startswith(spr) and len(lump) == 8 and lump[6:8] in (fr + '0', fr + '1'):
            return lump, True, info
    return None, False, None


def liquid_flats(packs):
    """BD's BD_CheckIfOverLiquid (SPLASH.acs): inventory name (lower) -> [floor textures that give it]."""
    out = {}
    for path, _ in packs:
        z = zipfile.ZipFile(path)
        for n in z.namelist():
            if n.lower().endswith('splash.acs'):
                t = z.read(n).decode('latin-1')
                m = re.search(r'script\s+"BD_CheckIfOverLiquid".*?\{(.*?)\n\}', t, re.S | re.I)
                if not m:
                    continue
                for flat, inv in re.findall(r'CheckActorFloorTexture\s*\(\s*0\s*,\s*"(\w+)"\s*\)\s*\)\s*\{\s*'
                                            r'GiveInventory\s*\(\s*"(\w+)"', m.group(1), re.I):
                    out.setdefault(inv.lower(), []).append(flat.upper())
        if out:
            break
    return out


# ------------------------------------------------------------------ walking states with their odds
class Ctx:
    def __init__(self, floor=None, take=(), water=False):
        self.floor = floor                      # A_CheckFloor answer (Death); None = never jumps
        self.take = {x.lower() for x in take}   # inventory jumps that are taken (A_JumpIfInventory names)
        self.water = water                      # under water (waterlevel 3) or on dry land (0): A_JumpIf(waterlevel ...)


WATER_RE = re.compile(r'^\s*waterlevel\s*(<=|>=|==|!=|<|>)\s*(\d+)\s*$', re.I)


def water_taken(cond, water):
    """An A_JumpIf(waterlevel <op> n) at waterlevel 3 (under water) or 0 (dry land); None if not that form."""
    m = WATER_RE.match(cond)
    if not m:
        return None
    wl, op, n = (3 if water else 0), m.group(1), int(m.group(2))
    return {'<': wl < n, '>': wl > n, '<=': wl <= n, '>=': wl >= n, '==': wl == n, '!=': wl != n}[op]


def resolve(world, key, definer, target):
    """A jump target: a quoted label (looked up on the actor's own class, as a jump is) or a state offset."""
    t = target.strip()
    if t.startswith('"'):
        r = world.find_label(key, unq(t))
        if r is None:
            return None
        k, ref = r
        return ('flow', k, ref[1]) if ref[0] == 'flow' else (k, ref[1])
    try:
        return int(float(t))
    except ValueError:
        return None


def explore(world, key, label, ctx, limit=4000):
    """Every path through `label` for class `key`: [{'w', 'steps': [(definer, idx, tic, tics, jumped, gate, noact)],
    'end'}]. end: ('stop', tic) | ('loop', tic, period) | ('park', tic) | ('none',).

    THE SPAWN STATE (label 'Spawn': every phase 1 class is spawned into it). The engine sets an actor's first state
    without calling its action (p_mobj.cpp AActor::Initialize: "action routines can not be called yet"); only a NoDelay
    state runs it, on the first tick (CheckNoDelay). That first tick comes in the tic the actor spawns and counts the
    state down by one (AActor::Tick: `if (--tics <= 0)`), so a first state of N tics shows for N-1 and a 0-tic one
    passes at once. Tic 0 here is that first tick: the first step's action is skipped (noact) unless NoDelay, and its
    tics are one less."""
    r = world.find_label(key, label)
    if r is None:
        return []
    d0, ref = r
    paths = []
    start = ('flow', d0, ref[1]) if ref[0] == 'flow' else (d0, ref[1])
    stack = [(start, 0, [], 1.0, {}, label.lower() == 'spawn')]
    guard = 0
    while stack:
        guard += 1
        if guard > limit:
            break
        loc, t, steps, w, seen, fresh = stack.pop()
        while True:
            if loc is None:
                paths.append({'w': w, 'steps': steps, 'end': ('stop', t)}); break
            if loc[0] == 'flow':
                d, f = loc[1], loc[2]
                if f[0] == 'goto':
                    g = world.goto(d, f[1])
                    loc = None if g is None else (('flow', g[1], g[2]) if g[0] == 'flow' else g)
                    if loc is None:
                        paths.append({'w': w, 'steps': steps, 'end': ('stop', t)}); break
                    continue
                if f[0] == 'loop':
                    loc = (d, f[1]); continue
                paths.append({'w': w, 'steps': steps, 'end': ('stop', t)}); break
            d, i = loc
            st = world.cls[d].states
            if st is None or i >= len(st.S):
                paths.append({'w': w, 'steps': steps, 'end': ('stop', t)}); break
            if loc in seen:
                paths.append({'w': w, 'steps': steps, 'end': ('loop', t, t - seen[loc])}); break
            seen = dict(seen); seen[loc] = t
            s = st.S[i]
            branches = None                    # [(weight share, target)] ; target None = fall through
            gate = None
            stics = s['tics']
            noact = False
            if fresh:
                # the spawn state: its tics less the first tick, its action only with NoDelay (see above)
                fresh = False
                if stics[0] >= 0:
                    stics = (max(0, stics[0] - 1), max(0, stics[1] - 1))
                noact = not s.get('nodelay')
            for name, args in ([] if noact else calls_in(s['action'])):
                nl = name.lower()
                if nl == 'a_jump' and args:
                    ch = fnum(args[0], 256)
                    tg = args[1:]
                    if not tg:
                        continue
                    if ch >= 255:
                        branches = [(1.0 / len(tg), x) for x in tg]
                    else:
                        p = ch / 256.0
                        branches = [(p / len(tg), x) for x in tg] + [(1.0 - p, None)]
                elif nl == 'a_jumpif' and len(args) >= 2 and 'floorz' in args[0].lower():
                    gate = args[0]
                elif nl == 'a_jumpif' and len(args) >= 2 and water_taken(args[0], ctx.water):
                    # BD's dry-land / under-water tests (Underblood's `waterlevel < 1` vanishes it out of water);
                    # a hit blood's and a drop's `waterlevel > 1` Splash is taken only in a water context
                    branches = [(1.0, args[1])]
                elif nl == 'a_checkfloor' and args and ctx.floor:
                    branches = [(1.0, args[0])]
                elif nl in ('a_jumpifinventory', 'a_jumpifintargetinventory') and len(args) >= 3 \
                        and unq(args[0]).lower() in ctx.take:
                    branches = [(1.0, args[2])]
            if branches is None:
                steps = steps + [(d, i, t, stics, False, gate, noact)]
                if stics[0] < 0:
                    paths.append({'w': w, 'steps': steps, 'end': ('park', t)}); break
                t += int(round((stics[0] + stics[1]) / 2.0))
                nx = st.nxt[i]
                if nx[0] == 'seq':
                    loc = (d, i + 1)
                elif nx[0] in ('stop', 'fail'):
                    paths.append({'w': w, 'steps': steps, 'end': ('stop', t)}); break
                elif nx[0] == 'wait':
                    paths.append({'w': w, 'steps': steps, 'end': ('park', t)}); break
                elif nx[0] == 'loop':
                    loc = (d, nx[1])
                else:
                    g = world.goto(d, nx[1])
                    loc = None if g is None else (('flow', g[1], g[2]) if g[0] == 'flow' else g)
                continue
            # a jump: the jumping state's own tics never run
            jsteps = steps + [(d, i, t, (0, 0), True, gate, noact)]
            first = True
            for share, tg in branches:
                if tg is None:
                    nloc = (d, i + 1) if st.nxt[i][0] == 'seq' else None
                    nsteps = steps + [(d, i, t, stics, False, gate, noact)]
                    nt = t + int(round((stics[0] + stics[1]) / 2.0))
                    if st.nxt[i][0] != 'seq':
                        nx = st.nxt[i]
                        if nx[0] == 'goto':
                            g = world.goto(d, nx[1])
                            nloc = None if g is None else (('flow', g[1], g[2]) if g[0] == 'flow' else g)
                        elif nx[0] == 'loop':
                            nloc = (d, nx[1])
                    stack.append((nloc, nt, nsteps, w * share, seen, False))
                    continue
                rr = resolve(world, key, d, tg)
                if isinstance(rr, int):
                    nloc = (d, i + rr)
                else:
                    nloc = rr
                stack.append((nloc, t, jsteps, w * share, seen, False))
                first = False
            break
    # merge identical step sequences (two jump targets that lead the same way)
    merged = {}
    for p in paths:
        k = (tuple((a, b, c) for a, b, c, _, _, _, _ in p['steps']), p['end'])
        if k in merged:
            merged[k]['w'] += p['w']
        else:
            merged[k] = p
    return sorted(merged.values(), key=lambda p: -p['w'])


# ------------------------------------------------------------------ what a path shows and does
def base_scale(world, key):
    s = fnum(world.pval(key, 'scale'), 1.0)
    return fnum(world.pval(key, 'xscale'), s), fnum(world.pval(key, 'yscale'), s)


def timeline(world, key, path, seed=None):
    """Frames shown and events done along one path. seed: the (xscale, yscale, alpha) the actor already has when it
    enters the path (A_SetScale and alpha persist on the actor: a Death path starts from what its flight left), else
    the class defaults. 'seed_end' is what it leaves."""
    if seed is not None:
        sx, sy, alpha = seed
    else:
        sx, sy = base_scale(world, key)
        alpha = fnum(world.pval(key, 'alpha'), 1.0)
    frames, events, unsupported = [], [], []
    end = path['end']
    removed = None
    gate_now, gate_left = None, 0       # BD's A_JumpIf((z - floorz) < 48, 2): it guards the A_RadiusGive right after it
    for n, (d, i, t, tics, jumped, gate, noact) in enumerate(path['steps']):
        if gate is not None:
            gate_now, gate_left = gate, 3
        prev_gate = gate_now if gate_left > 0 else None
        gate_left -= 1
        s = world.cls[d].states.S[i]
        for name, args in ([] if noact else calls_in(s['action'])):
            nl = name.lower()
            if nl == 'a_setscale' and args:
                nx = eval_scale(args[0], sx, sy)
                ny = eval_scale(args[1], sx, sy) if len(args) > 1 else None
                if nx is not None:
                    if ny is None or ny == 0:
                        ny = nx
                    sx, sy = nx, ny
            elif nl == 'a_fadeout':
                alpha -= fnum(args[0], 0.1) if args else 0.1
                if alpha <= 0:
                    removed = t
            elif nl == 'a_fadein':
                alpha = min(1.0, alpha + (fnum(args[0], 0.1) if args else 0.1))
            elif nl == 'a_settranslucent' and args:
                alpha = fnum(args[0], alpha)
            elif nl in ('a_playsound', 'a_startsound') and args:
                events.append(('sound', t, unq(args[0])))
            elif nl in [f.lower() for f in decorate.SPAWN_FUNCS] and args and args[0].strip().startswith('"'):
                events.append(('spawn', t, nl, unq(args[0]), args[1:], n))
            elif nl == 'a_radiusgive' and args:
                events.append(('give', t, unq(args[0]), fnum(args[1] if len(args) > 1 else 0, 0),
                               args[2] if len(args) > 2 else '0', prev_gate, n))
            elif nl.startswith('acs_'):
                events.append(('acs', t, unq(args[0]) if args else '?', n))
            elif nl == 'radius_quake':
                events.append(('quake', t, [fnum(a, 0) for a in args]))
            elif nl in ('a_jumpifintargetinventory',):
                events.append(('tinv', t, unq(args[0]) if args else '', args[1:] if args else [], n))
            elif nl == 'a_jumpif' and args and 'waterlevel' in args[0].lower():
                events.append(('water', t, args[0], args[1] if len(args) > 1 else '', n))
            elif nl in ('a_stop',):
                events.append(('stopmove', t))
        if removed is not None:
            break
        if not jumped and tics[0] > 0 and s['sprite'] not in INVISIBLE:
            frames.append({'spr': s['sprite'], 'fr': s.get('frame', 'A'), 't': t,
                           'tics': int(round((tics[0] + tics[1]) / 2.0)), 'sx': sx, 'sy': sy, 'alpha': alpha,
                           'bright': s.get('bright', False)})
    if removed is not None:
        end_t = removed
    elif end[0] in ('stop',):
        end_t = end[1]
    else:
        end_t = None
    return {'frames': frames, 'events': events, 'end': end, 'end_t': end_t, 'alpha_end': max(0.0, alpha),
            'removed': removed is not None, 'seed_end': (sx, sy, max(0.0, alpha))}


# ------------------------------------------------------------------ looks (textures) and variants (particles)
class SpriteSource:
    """BD's and XMVE's sprite frames, decoded on demand (cached): RGBA texels, the frame's offsets, and its opaque
    bounding box. Every look frame is baked from here (write_bakes), TRIMMED to that box: a particle texture is drawn
    without the alpha test (hw_sprites.cpp: STYLEHW_NoAlphaTest), so a frame's empty margin only costs texture space."""

    def __init__(self, packs, wad):
        self.where = {}
        for path, _ in packs:                     # later packs win, as the engine loads them
            z = zipfile.ZipFile(path)
            for n in z.namelist():
                ln = n.replace('\\', '/').lower()
                if ln.startswith('sprites/') and not ln.endswith('/'):
                    self.where[n.split('/')[-1].split('.')[0].upper()] = (path, n)
        self.wad = wad
        self.pal = read_playpal(wad) if wad and os.path.isfile(wad) else None
        self.match = Matcher(self.pal) if self.pal else None
        self.zips = {}
        self.cache = {}

    def decode(self, lump):
        """(w, h, [(r, g, b, a)], [palette index or -1], xoff, yoff) or None."""
        if lump in self.cache:
            return self.cache[lump]
        out = None
        if lump in self.where:
            path, n = self.where[lump]
            data = self.zips.setdefault(path, zipfile.ZipFile(path)).read(n)
            info = read_sprite_info(data[:4096])
            png = decode_png(data)
            if png and info:
                w, h, pix = png
                idx = engine_indices(data[25], pix, self.match)
                out = (w, h, pix, idx, info[2], info[3])
            elif self.pal and info:
                pt = decode_patch(data)
                if pt:
                    w, h, px = pt
                    pix = [(self.pal[i] + (255,)) if i >= 0 else (0, 0, 0, 0) for i in px]
                    out = (w, h, pix, px, info[2], info[3])
        self.cache[lump] = out
        return out

    def trimmed(self, lump, fallback):
        """(w, h, xoff, yoff) of the frame cut to its opaque box; the untrimmed header info if it cannot be decoded."""
        d = self.decode(lump)
        if d is None:
            return fallback
        w, h, pix, idx, xo, yo = d
        box = bbox(w, h, pix)
        if box is None:
            return (1, 1, xo, yo)
        x0, y0, x1, y1 = box
        return (x1 - x0, y1 - y0, xo - x0, yo - y0)


def bbox(w, h, pix):
    """The opaque box (x0, y0, x1, y1), exclusive ends, or None if every texel is clear."""
    xs = [i % w for i, p in enumerate(pix) if p[3]]
    if not xs:
        return None
    ys = [i // w for i, p in enumerate(pix) if p[3]]
    return (min(xs), min(ys), max(xs) + 1, max(ys) + 1)


class Looks:
    """The frames the tracks show. Every frame BD draws becomes one baked texture of ours (graphics/rsqgo/RSQGOnnn.png:
    BD's frame cut to its opaque box with its offsets kept, recoloured through BD's translation for green / blue /
    alien), numbered in first-use order; the VisualThinker that plays a track shows it exactly as BD's actor would show
    BD's sprite (same texels, same offsets, same scale; hw_sprites.cpp AdjustVisualThinker vs HWSprite::Process)."""

    def __init__(self, sprites, src=None):
        self.sprites = sprites
        self.src = src
        self.tex = {}            # (lump, translation key) -> texture index
        self.texlist = []        # [(lump, translation key)]
        self.trans_of = {}       # translation key -> BD's translation string
        self.missing = set()

    def resolve(self, spr, fr):
        """(lump, flipped) for a sprite frame, or (None, False)."""
        lump, flipped, info = frame_lump(self.sprites, spr, fr)
        return lump, flipped

    def tex_index(self, lump, trans):
        # Every frame is BD's own, untranslated: a coloured class's VisualThinker is drawn through that class's own
        # Translation at run time (emit.zs SpawnVT: GetDefaultByType(BD's class).Translation), so the engine squashes
        # it to the palette with 1-bit alpha and recolours it exactly as it does BD's actor, with the palette the game
        # really runs (a later pack's PLAYPAL, e.g. LegionOfBones', changes BD's blue; no offline bake can know it).
        tk = ''
        key = (lump, tk)
        if key not in self.tex:
            self.tex[key] = len(self.texlist)
            self.texlist.append(key)
        return self.tex[key]


def variant_of(looks, trans, tl):
    """One TRACK from a timeline (one random branch of BD's states), or None if it shows nothing:
    {'start': first visible tic, 'life': tics from start to BD's removal, 'loop_from'/'loop_per': a looping state's
    repeat (else 0), 'kf': [(tic from start, texture index or -1 hidden, xscale, yscale, alpha, bright)]}.
    One keyframe per state BD enters, with the values that state shows: its frame, the scale after its A_SetScale (an
    absolute value or BD's scalex+d growth), the alpha after its A_FadeOut / A_FadeIn / A_SetTranslucent, and Bright. A
    negative scale is BD's mirror; a frame stored as the second half of a paired lump is mirrored too."""
    fr = tl['frames']
    if not fr:
        return None
    start = fr[0]['t']
    if tl['end_t'] is not None:
        end = tl['end_t']
    else:
        end = start + LIFE_CAP
    kfs = []
    prev_end = start
    for x in fr:
        lump, flipped = looks.resolve(x['spr'], x['fr'])
        if lump is None:
            looks.missing.add(x['spr'] + x['fr'])
            end = min(end, x['t'])             # BD draws nothing from here on: our track ends
            break
        if x['t'] > prev_end:
            kfs.append((prev_end - start, -1, 0.0, 0.0, 0.0, False))      # a TNT1 stretch: hidden
        tex = looks.tex_index(lump, trans)
        sx = -x['sx'] if flipped else x['sx']
        kfs.append((x['t'] - start, tex, sx, x['sy'], max(0.0, x['alpha']), bool(x['bright'])))
        prev_end = x['t'] + x['tics']
    if not kfs:
        return None
    if tl['end'][0] != 'loop' and prev_end < end:
        end = prev_end                         # BD shows nothing after its last visible frame: the track ends there
    # merge keyframes that change nothing
    merged = []
    for k in kfs:
        if merged and merged[-1][1:] == k[1:]:
            continue
        merged.append(k)
    loop_from = loop_per = 0
    if tl['end'][0] == 'loop':
        loop_per = max(1, tl['end'][2])
        loop_from = max(0, tl['end'][1] - loop_per - start)
    return {'start': start, 'life': max(1, end - start), 'kf': merged, 'loop_from': loop_from, 'loop_per': loop_per}


def track_scale(v):
    """(first, last) absolute geometric scale over a track's visible keyframes (for the summary and track_report)."""
    vis = [k for k in v['kf'] if k[1] >= 0]
    if not vis:
        return (0.0, 0.0)
    g = lambda k: math.sqrt(abs(k[2] * k[3])) if k[2] and k[3] else abs(k[2] or k[3])
    return (g(vis[0]), g(vis[-1]))


# ------------------------------------------------------------------ child spawns
SPAWN_SUPPORTED = ('a_custommissile', 'a_spawnprojectile', 'a_spawnitemex', 'a_spawnitem')


def child_of(ev, card_index, world):
    """A spawn event -> child dict, or (None, reason)."""
    _, t, func, cls, args, sidx = ev
    if func not in SPAWN_SUPPORTED:
        return None, 'spawn function %s' % func
    c = {'tic': t, 'sidx': sidx, 'cls': cls, 'card': card_index.get(cls.lower(), -1), 'count': 1, 'interval': 0,
         'flags': 0, 'r': [(0.0, 0.0)] * 7}
    a = args + [''] * 10
    if func in ('a_custommissile', 'a_spawnprojectile'):
        h, ang, fl, pit = rng(a[0], (32.0, 32.0)), rng(a[2]), rng(a[3]), rng(a[4])
        if None in (h, ang, pit) or fl is None:
            return None, 'missile arguments %s' % ', '.join(args)
        c['mode'] = M_MISSILE
        flags = int(fl[0])
        if func == 'a_spawnprojectile':
            pit = (-pit[1], -pit[0])           # A_CustomMissile's pitch is up-positive (CMF_BADPITCH); fix it to match
        c['flags'] = flags
        c['r'] = [h, ang, pit, (0.0, 0.0), (0.0, 0.0), (0.0, 0.0), (0.0, 0.0)]
        if (flags & 3) != 2:
            return None, 'missile aim mode %d (only CMF_AIMDIRECTION is reproduced)' % (flags & 3)
    elif func == 'a_spawnitemex':
        vals = [rng(a[k]) for k in range(7)]
        if None in vals:
            return None, 'A_SpawnItemEx arguments %s' % ', '.join(args)
        c['mode'] = M_ITEMEX
        c['r'] = vals                          # x, y, z, vx, vy, vz, angle
        flags = 0
        for tok in re.split(r'\s*\|\s*', a[7].strip()):
            tk = tok.strip().upper()
            if tk in ('', '0'):
                continue
            bits = {'SXF_ABSOLUTEPOSITION': 2, 'SXF_ABSOLUTEANGLE': 4, 'SXF_ABSOLUTEVELOCITY': 8,
                    'SXF_ABSOLUTEMOMENTUM': 8}
            flags |= bits.get(tk, 0)
            try:
                flags |= int(tk)
            except ValueError:
                pass
        c['flags'] = flags
    else:
        dist, zh = rng(a[0]), rng(a[1])
        if dist is None or zh is None:
            return None, 'A_SpawnItem arguments %s' % ', '.join(args)
        c['mode'] = M_ITEM
        c['r'] = [dist, zh, (0.0, 0.0), (0.0, 0.0), (0.0, 0.0), (0.0, 0.0), (0.0, 0.0)]
    return c, None


def compress(children):
    """Equal spawns at a steady interval (a trail spawned every tic) become one child with count and interval."""
    out = []
    for c in children:
        if out:
            p = out[-1]
            same = (p['cls'].lower() == c['cls'].lower() and p['mode'] == c['mode'] and p['r'] == c['r']
                    and p['flags'] == c['flags'])
            if same:
                gap = c['tic'] - (p['tic'] + p['interval'] * (p['count'] - 1))
                if p['count'] == 1 or gap == p['interval']:
                    if p['count'] == 1:
                        p['interval'] = gap
                    if gap == p['interval']:
                        p['count'] += 1
                        continue
        out.append(dict(c))
    return out


# ------------------------------------------------------------------ the cards
def card_flags(world, key):
    fl = world.flags(key)
    bounce = fl.get('_bounce', False) or any(fl.get(f) for f in decorate.BOUNCE_FLAGS)
    return fl, bounce


def make_cards(world, rows, packs, wad=None):
    sprites = load_sprites(packs)
    src = SpriteSource(packs, wad)
    looks = Looks(sprites, src)
    flats = liquid_flats(packs)
    phase1 = [r for r in rows if r['label'] in PHASE1 and r['owner'] == 'gore']
    # pass 1: which classes become cards (a hit blood needs BD's intensity script; the rest by what they do)
    keys = [r['key'] for r in phase1]
    pre = {}
    for r in phase1:
        k = r['key']
        if LEAVE_NAMES.search(r['class']):
            pre[k] = ('leave', 'drawn by a MODELDEF md3 (a flat on the water): stays BD\'s actor; our liquid checker '
                               'spawns it by name, as BD\'s does')
            continue
        if r['label'] == 'hit blood':
            p = explore(world, k, 'Spawn', Ctx())
            acs = p and any(e[0] == 'acs' and e[2].lower() == 'bd_checkbloodintensity' for e in timeline(world, k, p[0])['events'])
            if acs:
                pre[k] = ('hit', None)
            else:
                pre[k] = ('drop?', None)
        elif r['label'] == 'liquid check':
            pre[k] = ('liquid', None)
        else:
            pre[k] = ('drop?', None)
    # provisional index (every non-left class), refined when a drop turns out unsupported
    card_index = {}
    for k in keys:
        if pre[k][0] != 'leave':
            card_index[k] = len(card_index)
    cards, left = [], []
    why_left = {k: pre[k][1] for k in keys if pre[k][0] == 'leave'}
    for _ in range(4):                          # repeat until no class drops out (a child may become BD's again)
        cards, left = [], []
        for k in keys:
            if k not in card_index:
                left.append((world.cls[k].name, why_left.get(k) or 'left'))
                continue
            kind = pre[k][0]
            if kind == 'hit':
                c, why = hit_card(world, k, card_index, looks)
            elif kind == 'liquid':
                c, why = liquid_card(world, k, card_index, flats)
            else:
                c, why = drop_card(world, k, card_index, looks, next(r['label'] for r in phase1 if r['key'] == k))
            if c is None:
                why_left[k] = why
                left.append((world.cls[k].name, why))
                continue
            c['key'], c['name'], c['cat'] = k, world.cls[k].name, CAT_CODE[next(r['label'] for r in phase1 if r['key'] == k)]
            cards.append(c)
        new_index = {c['key']: i for i, c in enumerate(cards)}
        if new_index == card_index:
            break
        card_index = new_index
        looks.__init__(sprites, src)
    looks.src = src
    return cards, left, looks, flats, card_index


def bounce_mask(world, k):
    """The surfaces a missile bounces off (B_*): its BounceType, then the flags in the order the chain sets them."""
    m = BOUNCE_TYPES.get((world.prop(k, 'bouncetype') or 'none').lower(), 0)
    fl = world.flags(k)
    for f, typ in (('doombounce', 'doom'), ('hexenbounce', 'hexen'), ('hereticbounce', 'heretic')):
        if fl.get(f):
            m = BOUNCE_TYPES[typ]
    for f, bit in (('bounceonwalls', B_WALLS), ('bounceonfloors', B_FLOORS), ('bounceonceilings', B_CEILINGS),
                   ('bounceautooff', B_AUTOOFF)):
        if f in fl:
            m = (m | bit) if fl[f] else (m & ~bit)
    return m


def common_props(world, k):
    fl, bounce = card_flags(world, k)
    # +NOINTERACTION: AActor::Tick only adds Vel to Pos (p_mobj.cpp), no gravity, no floor, no walls
    grav = 0.0 if (fl.get('nogravity') or fl.get('nointeraction')) else fnum(world.pval(k, 'gravity'), 1.0)
    style = (world.pval(k, 'renderstyle', 'normal') or 'normal').lower()
    decal = world.pval(k, 'decal')
    if decal and decal.lower() == 'none':
        decal = None
    return {'speed': fnum(world.pval(k, 'speed'), 0.0), 'grav': grav, 'missile': bool(fl.get('missile')),
            'noclip': bool(fl.get('noclip')), 'nointeraction': bool(fl.get('nointeraction')), 'bounce': bounce,
            'bmask': bounce_mask(world, k) if bounce else 0,
            'wallbf': fnum(world.pval(k, 'wallbouncefactor'), 0.75), 'bf': fnum(world.pval(k, 'bouncefactor'), 0.7),
            'mass': fnum(world.pval(k, 'mass'), 100.0),
            'style': STYLES.get(style, 'STYLE_Translucent'), 'decal': decal or '',
            'radius': fnum(world.pval(k, 'radius'), 20.0), 'height': fnum(world.pval(k, 'height'), 16.0),
            'trans': world.prop(k, 'translation'),
            'puffowner': bool(fl.get('puffgetsowner')), 'donttranslate': bool(fl.get('donttranslate'))}


def track_key(v):
    return (v['start'], v['life'], v['loop_from'], v['loop_per'],
            tuple((k[0], k[1], round(k[2], 4), round(k[3], 4), round(k[4], 4), k[5]) for k in v['kf']))


def variants_from(world, k, paths, looks, trans, seed=None):
    """The tracks of a set of paths, equal ones merged (odds summed). Each keeps 'seed': the scale and alpha its
    heaviest path leaves the actor with (a landing splash starts from it)."""
    vs = {}
    order = []
    for p in paths:
        tl = timeline(world, k, p, seed)
        v = variant_of(looks, trans, tl)
        if v is None:
            continue
        vk = track_key(v)
        if vk in vs:
            vs[vk]['w'] += p['w']
        else:
            v['w'] = p['w']
            v['seed'] = tl['seed_end']
            vs[vk] = v
            order.append(vk)
    return [vs[x] for x in order]


def children_from(world, events, card_index, path_id, base=0, until=None):
    kids, gives, why = [], [], None
    for ev in events:
        if until is not None and ev[1] >= until:
            continue
        if ev[0] == 'spawn':
            c, w = child_of(ev, card_index, world)
            if c is None:
                return None, None, w
            c['path'] = path_id
            c['tic'] = ev[1] - base
            kids.append(c)
        elif ev[0] == 'give':
            gate = None
            if ev[5]:
                m = re.search(r'<\s*(\d+)', ev[5])
                gate = float(m.group(1)) if m else 48.0
            gives.append({'path': path_id, 'tic': ev[1] - base, 'cls': ev[2], 'radius': ev[3], 'flags': ev[4],
                          'gate': gate, 'sidx': ev[6]})
    return compress(kids), gives, why


def splash_groups(world, k, paths, looks, trans, flights):
    """The splash tracks of a Death path, one GROUP per flight track: BD's Death runs on the same actor, so it shows at
    the scale, mirror and alpha that flight left (timeline seed). grp = the flight track's index; when every group is
    the same, one group with grp -1 (any flight)."""
    seeds = [v.get('seed') for v in flights] or [None]
    groups = [variants_from(world, k, paths, looks, trans, sd) for sd in seeds]
    keys = [[(track_key(v), round(v['w'], 6)) for v in g] for g in groups]
    if all(x == keys[0] for x in keys):
        out = groups[0]
        for v in out:
            v['grp'] = -1
        return out
    out = []
    for gi, g in enumerate(groups):
        for v in g:
            v['grp'] = gi
            out.append(v)
    return out


def landing(world, k, card_index, looks, trans, flights=()):
    """What happens when the drop dies on the floor and on a wall: spot class, splash variants (grouped per flight
    track), sound, children."""
    out = {'spot': '', 'splash': [], 'sound': '', 'floorkids': [], 'wallkids': [], 'wallsplash': []}
    for floor in (True, False):
        paths = explore(world, k, 'Death', Ctx(floor=floor))
        if not paths:
            continue
        tl = timeline(world, k, paths[0])
        kids, gives, why = children_from(world, tl['events'], card_index, P_FLOOR if floor else P_WALL)
        if kids is None:
            return None, 'Death: ' + why
        snd = next((e[2] for e in tl['events'] if e[0] == 'sound'), '')
        v = splash_groups(world, k, paths, looks, trans, flights)
        if floor:
            spots = [c for c in kids if c['card'] < 0]
            out['spot'] = spots[0]['cls'] if spots else ''
            out['floorkids'] = [c for c in kids if c not in spots[:1]]
            out['splash'] = v
            out['sound'] = snd
        else:
            out['wallkids'] = kids
            out['wallsplash'] = v
            out['sound'] = out['sound'] or snd
    return out, None


def water_children(world, k, card_index, events):
    w = next((e for e in events if e[0] == 'water' and '>' in e[2]), None)
    if not w:
        return []
    paths = explore(world, k, unq(w[3]), Ctx()) if w[3].strip().startswith('"') else []
    if not paths:
        return []
    kids, gives, why = children_from(world, timeline(world, k, paths[0])['events'], card_index, P_WATER)
    for c in kids or []:
        c['tic'] += w[1]                     # the Splash state is entered at the water check
    return kids or []


def drop_card(world, k, card_index, looks, label):
    cp = common_props(world, k)
    paths = explore(world, k, 'Spawn', Ctx())
    if not paths:
        return None, 'no Spawn state'
    tl = timeline(world, k, paths[0])
    for e in tl['events']:
        if e[0] == 'acs':
            return None, 'runs ACS %s' % e[2]
        if e[0] == 'tinv':
            return None, 'checks its target\'s inventory (%s)' % e[2]
        if e[0] == 'give' and not (e[2].lower().startswith('bloodsplasher') and 'monsters' not in e[4].lower()):
            return None, 'gives %s' % e[2]
    kids, gives, why = children_from(world, tl['events'], card_index, P_DROP)
    if kids is None:
        return None, why
    if label == 'hit blood' and any(c['card'] < 0 for c in kids):
        # a "blood" that only spawns BD actors (a metal hit puff, ricochets, bone dust): nothing to save, so BD keeps it
        return None, 'spawns BD actors (%s), no liquid to replace' % ', '.join(sorted({c['cls'] for c in kids if c['card'] < 0}))
    for p in paths[1:]:
        k2, _, _ = children_from(world, timeline(world, k, p)['events'], card_index, P_DROP)
        if k2 is not None and [(c['cls'], c['tic']) for c in k2] != [(c['cls'], c['tic']) for c in kids] and p['w'] >= 0.25:
            return None, 'its random branches spawn different things'
    if tl['end'][0] == 'loop':
        # a looping class (PlayerFlyingBlood) spawns its children on every pass until it lands: repeat them to the cap
        per = tl['end'][2]
        for c in kids:
            if per > 0 and c['tic'] >= tl['end'][1] - per:
                step = c['interval'] if c['count'] > 1 and c['interval'] > 0 else per
                c['interval'] = step
                c['count'] = max(1, LIFE_CAP // step)
    v = variants_from(world, k, paths, looks, cp['trans'])
    land, why = landing(world, k, card_index, looks, cp['trans'], v)
    if land is None:
        return None, why
    # under water a class whose Spawn tests waterlevel shows something else (Underblood plays out only there; on dry
    # land its `waterlevel < 1` jump removes it at once): those tracks too, flagged wet (emit.zs picks by its water)
    wet = []
    if not water_children(world, k, card_index, tl['events']):
        vw = variants_from(world, k, explore(world, k, 'Spawn', Ctx(water=True)), looks, cp['trans'])
        if [track_key(x) for x in vw] != [track_key(x) for x in v]:
            wet = vw
            for x in wet:
                x['wet'] = True
    life = tl['end_t'] if tl['end_t'] is not None else LIFE_CAP
    c = dict(cp)
    c.update({'kind': KIND_DROP, 'variants': v + wet, 'kids': kids + land['floorkids'] + land['wallkids'] +
              water_children(world, k, card_index, tl['events']), 'gives': gives, 'life': life, 'land': land,
              'sound': '', 'puff': [], 'slaughter': False, 'saw': False, 'lspot': '', 'ldist': 0.0, 'ldelay': 0,
              'lflats': [], 'stopmove': any(e[0] == 'stopmove' for e in tl['events']), 'acs_tic': 0})
    return c, None


def route_events(world, k, label, ctx, card_index, path_id):
    """Children and gives along a label's first path, to its end (its Goto LowBlood included), tics from its entry."""
    paths = explore(world, k, label, ctx)
    if not paths:
        return [], [], None
    kids, gives, why = children_from(world, timeline(world, k, paths[0])['events'], card_index, path_id)
    if kids is None:
        return None, None, why
    return kids, gives, None


def cut_frames(frames, at):
    """The frames an actor shows before tic `at` (a state set at `at` replaces whatever it was showing)."""
    out = []
    for f in frames:
        if f['t'] >= at:
            continue
        g = dict(f)
        g['tics'] = min(g['tics'], at - g['t'])
        out.append(g)
    return out


def seed_at(world, k, path, at):
    """The scale and alpha the actor has after every step of `path` up to and including tic `at` (the blood ticks
    before BD's script acts in that tic)."""
    steps = [x for x in path['steps'] if x[2] <= at]
    return timeline(world, k, {'w': 1.0, 'steps': steps, 'end': ('stop', at)})['seed_end']


def route_puffs(world, k, looks, trans, own, at, label, ctx):
    """The puff tracks of a blood that BD's script sends into `label` at tic `at`: what each own branch showed before
    `at`, then the label's frames (from the scale it left), each pair of branches with its odds."""
    vs, order = {}, []
    for po in own:
        tl_o = timeline(world, k, po)
        pre = cut_frames(tl_o['frames'], at)
        sd = seed_at(world, k, po, at)
        for pr in explore(world, k, label, ctx):
            tl_r = timeline(world, k, pr, sd)
            fr = list(pre)
            for f in tl_r['frames']:
                g = dict(f)
                g['t'] += at
                fr.append(g)
            end_t = at + tl_r['end_t'] if tl_r['end_t'] is not None else None
            fake = {'frames': fr, 'end': ('stop', end_t or 0) if end_t is not None else tl_r['end'], 'end_t': end_t,
                    'alpha_end': tl_r['alpha_end'], 'removed': tl_r['removed']}
            v = variant_of(looks, trans, fake)
            if v is None:
                continue
            vk = track_key(v)
            if vk in vs:
                vs[vk]['w'] += po['w'] * pr['w']
            else:
                v['w'] = po['w'] * pr['w']
                vs[vk] = v
                order.append(vk)
    return [vs[x] for x in order]


def hit_card(world, k, card_index, looks):
    """A standard hit blood (Brutal_Blood and its colour and saw versions): every blood-level path.

    WHEN BD'S INTENSITY SCRIPT ACTS. ACS_NamedExecuteAlways("BD_CheckBloodIntensity") only starts the script; it runs
    when the ACS thinker ticks (STAT_SCRIPTS, after every actor: statnums.h) and waits Delay(1) before its
    SetActorState. A blood spawned this tic runs its 0-tic chain in its first tick, in the fresh-thinker pass AFTER the
    ACS thinker (dthinker.cpp RunThinkers), so the script first runs a tic later and acts two tics after the call, and
    then after the blood's own tick of that tic. By then BSPR A 2 has run out and the blood has done Spawn2 and its
    LowBlood (screen blood, BSPR B): every level gets the level-2 set, then the level's state on top (BD's actual
    behaviour, not its intended table). A P_SpawnBlood blood started 1 or 2 states in runs its chain before its first
    tick instead, which moves the whole timeline one tic earlier (emit.zs RunHit: `sh`)."""
    cp = common_props(world, k)
    own = explore(world, k, 'Spawn', Ctx())
    main = own[0]
    tl = timeline(world, k, main)
    ev = tl['events']
    acs = next(e for e in ev if e[0] == 'acs' and e[2].lower() == 'bd_checkbloodintensity')
    t_acs = acs[1]
    acs_at = t_acs + (2 if t_acs == 0 else 1)
    if world.find_label(k, 'LowBlood') is None:
        return None, 'no LowBlood state'
    # the chain before the script starts (the low-damage start skips by state index), then the blood's own path
    common = [e for e in ev if e[1] <= t_acs]
    level2 = [e for e in ev if e[1] > t_acs]
    kids_c, gives_c, why = children_from(world, common, card_index, P_COMMON)
    if kids_c is None:
        return None, why
    kids_2, gives_2, why = children_from(world, level2, card_index, P_LEVEL2)
    if kids_2 is None:
        return None, why
    out_kids, out_gives = kids_c + kids_2, gives_c + gives_2
    # the level states, each from its entry (emit.zs adds the script's tic)
    jump = absurd_animu_split(world, k)
    for label, path_id in (('LowBlood', P_LOW), ('LotsOfBlood', P_LOTS), ('AbsurdBlood', P_ABSURD)):
        if world.find_label(k, label) is None:
            continue
        kk, gg, why = route_events(world, k, label, Ctx(), card_index, path_id)
        if kk is None:
            return None, '%s: %s' % (label, why)
        if label == 'AbsurdBlood':
            # level 5 gives AnimuGore first, and AbsurdBlood jumps to AnimuGore after its wall throws: what comes
            # after that jump (level 4's spawns and its LowBlood) belongs to level 4 only, the walls before it to both.
            for x in kk + gg:
                x['animu_skip'] = jump is not None and x['sidx'] > jump[1]
        out_kids += kk
        out_gives += gg
    if jump is not None:
        # level 5: AbsurdBlood with AnimuGore taken, from the jump on (AnimuGore and its LowBlood), tics from
        # AbsurdBlood's entry: the animu spawns come with the walls, after AbsurdBlood's TNT1 A 2
        pa = explore(world, k, 'AbsurdBlood', Ctx(take=('AnimuGore',)))
        if pa:
            evs = [e for e in timeline(world, k, pa[0])['events']
                   if (e[0] == 'spawn' and e[5] > jump[1]) or (e[0] == 'give' and e[6] > jump[1])]
            kk, gg, why = children_from(world, evs, card_index, P_ANIMU)
            if kk is None:
                return None, 'AnimuGore: ' + why
            out_kids += kk
            out_gives += gg
    # water: the Splash label (BD: waterlevel > 1 at the check)
    out_kids += water_children(world, k, card_index, ev)
    # the saw branch
    saw = next((e for e in ev if e[0] == 'tinv' and e[2].lower() == 'hascutingweapon'), None)
    saw_sidx, saw_tic, sawsound, quake, saw_fx = -1, 0, '', None, 0
    if saw:
        saw_sidx, saw_tic = saw[-1], saw[1]
        tg = saw[3][1] if len(saw[3]) > 1 else ''
        sp = explore(world, k, unq(tg), Ctx())
        if sp:
            stl = timeline(world, k, sp[0])
            kk, gg, why = children_from(world, stl['events'], card_index, P_SAW)
            if kk is None:
                return None, 'HitSaw: ' + why
            out_kids += kk
            out_gives += gg
            sawsound = next((e[2] for e in stl['events'] if e[0] == 'sound'), '')
            quake = next((e[2] for e in stl['events'] if e[0] == 'quake'), None)
            saw_fx = next((e[1] for e in stl['events'] if e[0] in ('sound', 'quake')), 0)
    sl = next((e for e in ev if e[0] == 'tinv' and e[2].lower() == 'slaughtercounter'), None)
    slaughter_n = (int(fnum(sl[3][0], 30)) if sl[3] else 30) if sl else 0
    sl_tic = sl[1] if sl else 0
    sound = next((e[2] for e in common if e[0] == 'sound'), '')
    # the puff, per route: level 2 is the blood's own path; the others are what it showed before the script acted,
    # then the level's state through LowBlood; the SlaughterCounter jump is LowBlood from the check
    puff = []
    routes = [(R_LEVEL2, None, None)]
    for rid, label, ctx in ((R_LOW, 'LowBlood', Ctx()), (R_LOTS, 'LotsOfBlood', Ctx()), (R_ABSURD, 'AbsurdBlood', Ctx()),
                            (R_ANIMU, 'AbsurdBlood', Ctx(take=('AnimuGore',)))):
        if world.find_label(k, label) is not None and (rid != R_ANIMU or jump is not None):
            routes.append((rid, label, ctx))
    for raw in (False,):                     # the translation is chosen at run time (emit.zs RunHit)
        tr = None
        for rid, label, ctx in routes:
            if label is None:
                vs = variants_from(world, k, own, looks, tr)
            else:
                vs = route_puffs(world, k, looks, tr, own, acs_at, label, ctx)
            for v in vs:
                v['route'], v['raw'] = rid, raw
            puff += vs
        if sl:
            vs = variants_from(world, k, explore(world, k, 'Spawn', Ctx(take=('SlaughterCounter',))), looks, tr)
            for v in vs:
                v['route'], v['raw'] = R_SLAUGHTER, raw
            puff += vs
    c = dict(cp)
    c.update({'kind': KIND_HIT, 'variants': [], 'kids': out_kids, 'gives': out_gives, 'life': 1,
              'land': {'spot': '', 'splash': [], 'sound': '', 'floorkids': [], 'wallkids': [], 'wallsplash': []},
              'sound': sound, 'puff': puff, 'slaughter': slaughter_n, 'saw': saw is not None,
              'saw_sidx': saw_sidx, 'saw_tic': saw_tic, 'sl_tic': sl_tic, 'saw_fx': saw_fx, 'sawsound': sawsound, 'quake': quake,
              'lspot': '', 'ldist': 0.0, 'ldelay': 0, 'lflats': [], 'stopmove': False, 'acs_tic': acs_at})
    return c, None


def absurd_animu_split(world, k):
    """(tic within AbsurdBlood, step index) of its A_JumpIfInventory("AnimuGore"), or None."""
    paths = explore(world, k, 'AbsurdBlood', Ctx())
    if not paths:
        return None
    for n, (d, i, t, tics, jumped, gate, noact) in enumerate(paths[0]['steps']):
        for name, args in calls_in(world.cls[d].states.S[i]['action']):
            if name.lower() == 'a_jumpifinventory' and args and unq(args[0]).lower() == 'animugore':
                return (t, n)
    return None


def liquid_card(world, k, card_index, flats):
    """WaterBloodCHecker: lands, then over a liquid floor leaves BD's WaterBloodSpot (7 tics later, 5 units ahead)."""
    cp = common_props(world, k)
    jumps = []
    paths = explore(world, k, 'Death', Ctx())
    if not paths:
        return None, 'no Death state'
    for (d, i, t, tics, jumped, gate, noact) in paths[0]['steps']:
        for name, args in calls_in(world.cls[d].states.S[i]['action']):
            if name.lower() == 'a_jumpifinventory' and args:
                jumps.append(unq(args[0]).lower())
    if not jumps:
        return None, 'no liquid test in Death'
    lp = explore(world, k, 'Death', Ctx(floor=True, take=jumps[:1]))
    tl = timeline(world, k, lp[0])
    sp = next((e for e in tl['events'] if e[0] == 'spawn'), None)
    if sp is None:
        return None, 'no liquid spot spawned'
    a = sp[4] + ['']
    dist = rng(a[0]) or (0.0, 0.0)
    fl = []
    for inv in jumps:
        fl += flats.get(inv, [])
    c = dict(cp)
    c.update({'kind': KIND_LIQUID, 'variants': [], 'kids': [], 'gives': [], 'life': 0,
              'land': {'spot': '', 'splash': [], 'sound': '', 'floorkids': [], 'wallkids': [], 'wallsplash': []},
              'sound': '', 'puff': [], 'slaughter': 0, 'saw': False, 'lspot': sp[3], 'ldist': dist[0], 'ldelay': sp[1],
              'lflats': sorted(set(fl)), 'stopmove': False, 'acs_tic': 0, 'liquid_invs': jumps})
    return c, None


# ------------------------------------------------------------------ writers
def f(x, nd=4):
    s = ('%.' + str(nd) + 'f') % x
    s = s.rstrip('0').rstrip('.') if '.' in s else s
    return '0' if s in ('-0', '') else s


def zstr(s):
    return '"%s"' % (s or '').replace('"', '')


# EVERY LOOK FRAME IS BAKED (graphics/rsqgo/RSQGOnnn.png): BD's own frame, untranslated, cut to its opaque box, its
# clear texels given the frame's mean colour at alpha 0 (nothing foreign to bleed in when filtered). Green, blue and
# alien are NOT baked: the VisualThinker carries BD's class Translation and the engine draws it exactly as it draws BD's
# actor (hw CreateTexBuffer(translation) -> image.cpp CopyTranslatedPixels -> CreatePalettedPixels: squashed to the
# running game palette with 1-bit alpha, then recoloured). The in-engine gallery (2026-11-27) showed why: BD's coloured
# mist and SuperGore are blocky and opaque, and BD's blue is the palette of whatever pack loads last (LegionOfBones'
# PLAYPAL in the owner's rotation), which an offline bake from doom2.wad cannot know. The colour-bake helpers below
# (translation_palette, engine_indices) stay for tools that need the engine's palette path offline.
BAKE_DIR = os.path.join('graphics', 'rsqgo')


def read_playpal(wad):
    """The first palette of PLAYPAL in a WAD: [(r, g, b)] x 256."""
    with open(wad, 'rb') as fh:
        data = fh.read()
    n, off = struct.unpack('<ii', data[4:12])
    for k in range(n):
        pos, size, name = struct.unpack('<ii8s', data[off + 16 * k:off + 16 * k + 16])
        if name.rstrip(b'\0').upper() == b'PLAYPAL':
            raw = data[pos:pos + 768]
            return [tuple(raw[3 * i:3 * i + 3]) for i in range(256)]
    raise ValueError('no PLAYPAL in ' + wad)


def trans_key(trans):
    """A translation string, spelled one way (spaces dropped): the same translation shares its looks and bakes."""
    return re.sub(r'\s+', '', trans) if trans else ''


def translation_palette(trans, pal):
    """BD's Translation string -> the 256 colours each palette index becomes (FRemapTable: identity, then the ranges)."""
    out = list(pal)
    for piece in re.findall(r'"([^"]*)"', trans):
        p = piece.replace(' ', '')
        m = re.match(r'^(\d+):(\d+)=(\d+):(\d+)$', p)
        if m:
            s, e, p1, p2 = (int(x) for x in m.groups())
            if s > e:
                s, e, p1, p2 = e, s, p2, p1
            if s == e:
                out[s] = pal[p1]
                continue
            col, step = float(p1), (p2 - p1) / float(e - s)
            for i in range(s, e + 1):
                out[i] = pal[int(round(col))]
                col += step
            continue
        m = re.match(r'^(\d+):(\d+)=\[(\d+),(\d+),(\d+)\]:\[(\d+),(\d+),(\d+)\]$', p)
        if m:
            s, e = int(m.group(1)), int(m.group(2))
            c1 = [float(x) for x in m.group(3, 4, 5)]
            c2 = [float(x) for x in m.group(6, 7, 8)]
            if s > e:
                s, e, c1, c2 = e, s, c2, c1
            n = max(1, e - s)
            for i in range(s, e + 1):
                t = (i - s) / float(n) if e > s else 0.0
                out[i] = tuple(int(c1[k] + (c2[k] - c1[k]) * t) for k in range(3))
            continue
        raise ValueError('translation form not baked: ' + piece)
    return out


def q256k(x):
    """The colour RGB256k stands for at x's 6-bit cell (v_colortables.cpp: Pick((r<<2)|(r>>4), ...) for r = x >> 2)."""
    r = x >> 2
    return (r << 2) | (r >> 4)


def engine_indices(ct, pix, match):
    """The palette index the engine gives each texel of a PNG when a Translation squashes it to the palette
    (image.cpp CopyTranslatedPixels -> pngtexture.cpp CreatePalettedPixels), -1 transparent: RGB / RGBA through the
    RGB256k table (imagehelpers.h RGBToPalette: alpha under 128 is transparent, everything else opaque); grey + alpha
    the same cut on its alpha; a paletted or grey PNG by its entries' nearest colour, transparent only where tRNS is 0."""
    if match is None:
        return [-1] * len(pix)
    out = []
    for (r, g, b, a) in pix:
        if ct in (2, 6):
            out.append(match.pick((q256k(r), q256k(g), q256k(b))) if a >= 128 else -1)
        elif ct == 4:
            out.append(match.pick((r, g, b)) if a >= 128 else -1)
        else:
            out.append(match.pick((r, g, b)) if a else -1)
    return out


class Matcher:
    """palette.cpp BestColor over indices 1-254 (squared RGB distance, first best wins), cached per colour."""

    def __init__(self, pal):
        self.pal = pal
        self.cache = {}

    def pick(self, rgb):
        hit = self.cache.get(rgb)
        if hit is not None:
            return hit
        r, g, b = rgb
        best, bd = 1, 1 << 30
        for i in range(1, 255):
            pr, pg, pb = self.pal[i]
            d = (r - pr) ** 2 + (g - pg) ** 2 + (b - pb) ** 2
            if d < bd:
                best, bd = i, d
                if d == 0:
                    break
        self.cache[rgb] = best
        return best


def decode_patch(data):
    """(w, h, [(palette index or -1)...]) for a Doom patch (column posts; -1 = transparent), else None."""
    if len(data) < 8:
        return None
    w, h, _, _ = struct.unpack('<hhhh', data[:8])
    if not (0 < w <= 4096 and 0 < h <= 4096) or len(data) < 8 + 4 * w:
        return None
    px = [-1] * (w * h)
    for x in range(w):
        (col,) = struct.unpack('<i', data[8 + 4 * x:12 + 4 * x])
        top = -1
        while 0 <= col < len(data):
            row = data[col]
            if row == 255:
                break
            top = row if row > top else top + row        # tall patches: DeePsea-style relative offsets
            ln = data[col + 1]
            for k in range(ln):
                y = top + k
                if 0 <= y < h and col + 3 + k < len(data):
                    px[y * w + x] = data[col + 3 + k]
            col += ln + 4
    return w, h, px


def write_png(path, w, h, rgba, xoff, yoff):
    """An RGBA PNG with a grAb chunk (the sprite offsets), filter 0, zlib level 9: the same bytes every run."""
    def chunk(typ, body):
        return struct.pack('>I', len(body)) + typ + body + struct.pack('>I', zlib.crc32(typ + body) & 0xFFFFFFFF)
    rows = bytearray()
    for y in range(h):
        rows.append(0)
        for (r, g, b, a) in rgba[y * w:(y + 1) * w]:
            rows += bytes((r, g, b, a))
    png = (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)) +
           chunk(b'grAb', struct.pack('>ii', xoff, yoff)) + chunk(b'IDAT', zlib.compress(bytes(rows), 9)) +
           chunk(b'IEND', b''))
    with open(path, 'wb') as fh:
        fh.write(png)


def bake_name(n):
    """RSQGO + 3 base-36 digits: 8 characters, so the lump's short name is unique on its own."""
    digits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    s = ''
    for _ in range(3):
        s = digits[n % 36] + s
        n //= 36
    return 'RSQGO' + s


def plan_bakes(looks):
    """(lump, translation key) -> baked lump name, for EVERY look frame (red ones under the key ''); sorted."""
    return {k: bake_name(i) for i, k in enumerate(sorted(set(looks.texlist)))}


def write_bakes(looks, packs, wad, root):
    """Writes every baked frame under root/BAKE_DIR (the folder is ours: stale files are removed). Returns the plan.
    Each frame is cut to its opaque box with its offsets moved to match (so it draws exactly where BD's frame draws),
    and its clear texels take the frame's mean blood colour at alpha 0, so no filtering can bleed a foreign colour in."""
    plan = plan_bakes(looks)
    folder = os.path.join(root, BAKE_DIR)
    os.makedirs(folder, exist_ok=True)
    keep = {v + '.png' for v in plan.values()}
    for fn in os.listdir(folder):
        if fn not in keep:
            os.remove(os.path.join(folder, fn))
    if not plan:
        return plan
    src = looks.src if looks.src else SpriteSource(packs, wad)
    if not src.pal:
        raise ValueError('no PLAYPAL: %s is needed to bake' % wad)
    tpal = {k: translation_palette(v, src.pal) for k, v in looks.trans_of.items()}
    for (lump, tk), name in sorted(plan.items(), key=lambda kv: kv[1]):
        d = src.decode(lump)
        if d is None:
            raise ValueError('cannot decode sprite %s for baking' % lump)
        w, h, pix, idx, xo, yo = d
        if tk:
            # BD's translated frame as the engine draws it: squashed to the palette with 1-bit alpha (opaque where the
            # engine keeps a texel), each index through BD's translation
            tp = tpal[tk]
            rgba = [(tp[i] + (255,)) if i >= 0 else (0, 0, 0, 0) for i in idx]
        else:
            rgba = [p if p[3] else (0, 0, 0, 0) for p in pix]      # BD's red as BD draws it: its own true colour
        box = bbox(w, h, rgba)
        if box is None:
            box = (0, 0, 1, 1)
        x0, y0, x1, y1 = box
        cw, ch = x1 - x0, y1 - y0
        crop = [rgba[(y0 + y) * w + x0 + x] for y in range(ch) for x in range(cw)]
        solid = [p for p in crop if p[3]]
        fill = tuple(sum(p[k] for p in solid) // len(solid) for k in range(3)) if solid else (0, 0, 0)
        crop = [p if p[3] else fill + (0,) for p in crop]
        write_png(os.path.join(folder, name + '.png'), cw, ch, crop, xo - x0, yo - y0)
    return plan


def zs_class_name(name):
    return 'RSQGO_K_' + name


def write_zscript(cards, looks, left, path, bd_name, plan):
    L = []
    w = L.append
    w('// RSQ Gore phase 1 cards -- GENERATED by Gore/tools/gen_gore.py (cards.py) from %s. Never hand-edit.' % bd_name)
    w('//')
    w('// 1. One small class per Brutal Doom class we take over (RSQGO_Manager.CheckReplacement swaps BD\'s class for it by')
    w('//    name). It carries BD\'s Speed, because A_CustomMissile sets a spawned missile\'s velocity from the SPAWNED')
    w('//    actor\'s Speed (p_actionfunctions.cpp A_SpawnProjectile), and its card number. Hit bloods also keep BD\'s Decal')
    w('//    and PUFFGETSOWNER (so target is the victim exactly where BD\'s blood had it).')
    w('// 2. RSQGO_Data.Build(): every card\'s data (what the class shows, spawns and leaves), built at run time from the')
    w('//    tables below. Ranges index into the track, keyframe, child, give and texture arrays. A TRACK is BD\'s actor')
    w('//    tic by tic (cards.py variant_of): keyframes of texture (our baked copy of BD\'s frame), x/y scale, alpha and')
    w('//    Bright, played by a VisualThinker (emit.zs RSQGO_VT) exactly as BD\'s actor shows its sprite.')
    w('')
    for i, c in enumerate(cards):
        base = 'RSQGO_HitBlood' if c['kind'] == KIND_HIT else 'RSQGO_Card'
        props = ['Speed %s;' % f(c['speed']), 'Height %s;' % f(c['height']), 'RSQGO_Card.CardNo %d;' % i]
        if c['kind'] == KIND_HIT:
            if c['decal']:
                props.append('Decal %s;' % zstr(c['decal']))
            if c['puffowner']:
                props.append('+PUFFGETSOWNER;')
            if c['donttranslate']:
                props.append('+DONTTRANSLATE;')
            # BD's own class translation as our default (2026-11-27): the engine overwrites it with the bleeder's
            # BloodTranslation when IT spawns the blood (P_SpawnBlood / P_BloodSplatter / P_BloodSplatter2, unless
            # DONTTRANSLATE), and a DECORATE spawn keeps it, exactly as with BD's actor. So emit.zs RunHit reads the
            # actor's Translation as it stands, with no guessing about who spawned it.
            if c.get('trans'):
                t = c['trans'].strip()
                props.append('Translation %s;' % (t if t.startswith('"') else zstr(t)))
        w('class %s : %s { Default { %s } }' % (zs_class_name(c['name']), base, ' '.join(props)))
    w('')
    w('extend class RSQGO_Data')
    w('{')
    w('\tconst NCARDS = %d;' % len(cards))
    w('\tconst NTEX = %d;' % len(looks.texlist))
    w('')
    # textures, by index: our baked frames (graphics/rsqgo)
    w('\tvoid BuildTex()')
    w('\t{')
    for key in looks.texlist:
        w('\t\tAddTex(%s);   // %s%s' % (zstr(plan[key]), key[0], ' (colour)' if key[1] else ''))
    w('\t}')
    # cards, chunked
    per = 24
    nfun = (len(cards) + per - 1) // per
    w('')
    w('\tvoid BuildCards()')
    w('\t{')
    for n in range(nfun):
        w('\t\tCards%d();' % n)
    w('\t}')
    for n in range(nfun):
        w('')
        w('\tprivate void Cards%d()' % n)
        w('\t{')
        for i in range(n * per, min(len(cards), (n + 1) * per)):
            c = cards[i]
            land = c['land']
            w('\t\t// %s' % c['name'])
            w('\t\tAddCard(%d, %d, %s, %s, %s, %s, %s, %s, %s, %s, %d, %s, %s, %s, %s, %d, %s, %s, %s);' % (
                c['kind'], c['cat'], zstr(c['name']), f(c['speed']), f(c['grav']), 'true' if c['missile'] else 'false',
                'true' if c['noclip'] else 'false', c['style'], zstr(c['decal']), zstr(land['spot']), c['life'],
                zstr(land['sound']), f(c['radius']), 'true' if c['stopmove'] else 'false',
                'true' if c['nointeraction'] else 'false', c['bmask'], f(c['wallbf']), f(c['bf']), f(c['mass'])))
            if c['kind'] == KIND_HIT:
                q = c['quake'] or []
                q = (q + [0, 0, 0, 0, 0])[:5]
                w('\t\tAddHit(%s, %d, %s, %d, %d, %s, %d, %d, %d, %d, %d, %d, %d);' % (
                    zstr(c['sound']), c['slaughter'], 'true' if c['saw'] else 'false', c.get('saw_sidx', -1),
                    c['acs_tic'], zstr(c.get('sawsound', '')), int(q[0]), int(q[1]), int(q[2]), int(q[3]),
                    c.get('saw_tic', 0), c.get('sl_tic', 0), c.get('saw_fx', 0)))
                for v in c['puff']:
                    w('\t\tAddPuff(%s, %d);' % (vargs(v), v['route']))
                    track_lines(w, v)
            if c['kind'] == KIND_LIQUID:
                w('\t\tAddLiquid(%s, %s, %d, %s);' % (zstr(c['lspot']), f(c['ldist']), c['ldelay'],
                                                   zstr(' '.join(c['lflats']))))
            for v in c['variants']:
                w('\t\tAddVar(%s%s);' % (vargs(v), ', true' if v.get('wet') else ''))
                track_lines(w, v)
            for v in land['splash']:
                w('\t\tAddSplash(%s, %d);' % (vargs(v), v.get('grp', -1)))
                track_lines(w, v)
            for v in land['wallsplash']:
                w('\t\tAddWSplash(%s, %d);' % (vargs(v), v.get('grp', -1)))
                track_lines(w, v)
            for kd in c['kids']:
                r = kd['r']
                w('\t\tAddKid(%d, %d, %d, %d, %s, %d, %d, %d, %d, %s, %s);' % (
                    kd['path'], kd['tic'], kd.get('sidx', 99) if kd['path'] == P_COMMON else 99, kd['card'],
                    zstr(kd['cls']), kd['mode'], kd['count'], kd['interval'], kd['flags'],
                    'true' if kd.get('animu_skip') else 'false',
                    ', '.join('%s, %s' % (f(a), f(b)) for a, b in r)))
            for g in c['gives']:
                w('\t\tAddGive(%d, %d, %s, %s, %s, %s, %s);' % (g['path'], g['tic'], zstr(g['cls']), f(g['radius']),
                                                           f(g['gate']) if g['gate'] is not None else '-1',
                                                           give_flags(g['flags']),
                                                           'true' if g.get('animu_skip') else 'false'))
        w('\t}')
    w('}')
    w('')
    w('// Left to Brutal Doom (phase 1 could not reproduce them; generated/cards_summary.txt says why): %d classes.' % len(left))
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')


def give_flags(s):
    s = str(s).upper()
    out = 0
    if 'PLAYERS' in s:
        out |= 1
    if 'MONSTERS' in s:
        out |= 2
    return str(out)


def vargs(v):
    return '%s, %d, %d, %d, %d' % (f(v['w']), v['start'], v['life'], v['loop_from'], v['loop_per'])


def track_lines(w, v):
    for (t, tex, sx, sy, a, br) in v['kf']:
        w('\t\tAddKf(%d, %d, %s, %s, %s, %s);' % (t, tex, f(sx, 4), f(sy, 4), f(a, 4), 'true' if br else 'false'))


def write_summary(cards, left, looks, flats, path, bd_name):
    L = ['RSQ Gore phase 1 cards -- GENERATED by Gore/tools/gen_gore.py (cards.py) from %s. Never hand-edit.' % bd_name,
         'What each phase 1 class becomes. kinds: hit = RSQGO_HitBlood (works in PostBeginPlay, gone on tic 1);',
         'drop = RSQGO_Card (emits its particles and children, schedules its floor spot, gone on tic 1);',
         'liquid = RSQGO_Card (tests the landing floor, leaves BD\'s liquid spot over a liquid).', '']
    kinds = {KIND_DROP: 'drop', KIND_HIT: 'hit', KIND_LIQUID: 'liquid'}
    L.append('== Cards: %d (tracks %d, keyframes %d, baked textures %d)' % (
        len(cards), sum(len(c['variants']) + len(c['puff']) + len(c['land']['splash']) + len(c['land']['wallsplash'])
                        for c in cards),
        sum(len(v['kf']) for c in cards for v in c['variants'] + c['puff'] + c['land']['splash'] + c['land']['wallsplash']),
        len(looks.texlist)))
    for i, c in enumerate(cards):
        land = c['land']
        bits = ['%s' % kinds[c['kind']], 'speed %s' % f(c['speed']), 'grav %s' % f(c['grav'])]
        if c['variants']:
            bits.append('%d track(s), life %d, scale %s' % (
                len(c['variants']), max(v['life'] + v['start'] for v in c['variants']),
                '/'.join('%s>%s' % tuple(f(s, 2) for s in track_scale(v)) for v in c['variants'])))
        if c['puff']:
            bits.append('puff %d track(s) (%s)' % (len(c['puff']), ', '.join(
                '%s%s %s>%s' % ((ROUTE_NAMES[v['route']], ' raw' if v['raw'] else '') + tuple(f(s, 2) for s in track_scale(v)))
                for v in c['puff'])))
        if c.get('bmask'):
            bits.append('bounces %s' % '+'.join(n for b, n in ((B_WALLS, 'walls'), (B_FLOORS, 'floors'),
                                                              (B_CEILINGS, 'ceilings'), (B_AUTOOFF, 'autooff'))
                                               if c['bmask'] & b))
        if c.get('nointeraction'):
            bits.append('nointeraction')
        if land['spot']:
            bits.append('floor spot %s' % land['spot'])
        if land['splash']:
            bits.append('splash%s' % (' per flight track' if any(v.get('grp', -1) >= 0 for v in land['splash']) else ''))
        if c['kids']:
            bits.append('children ' + ', '.join('%s%s@%d%s/%s' % (
                k['cls'], ('x%d' % k['count']) if k['count'] > 1 else '', k['tic'],
                ('+%d' % k['interval']) if k['count'] > 1 else '', PATH_NAMES[k['path']]) for k in c['kids']))
        if c['gives']:
            bits.append('gives ' + ', '.join('%s r%s%s' % (g['cls'], f(g['radius']), ' if 48+ up' if g['gate'] else '')
                                             for g in c['gives']))
        if c['kind'] == KIND_LIQUID:
            bits.append('liquid spot %s on %s' % (c['lspot'], ' '.join(c['lflats']) or 'NO FLATS FOUND'))
        if c['decal']:
            bits.append('decal %s' % c['decal'])
        L.append('  %3d %-32s %s' % (i, c['name'], '; '.join(bits)))
    L.append('')
    L.append('== Left to BD: %d' % len(left))
    for name, why in left:
        L.append('  %-32s %s' % (name, why))
    L.append('')
    L.append('== Sprite frames not found in either pack (a look using one is dropped): %s' % (
        ', '.join(sorted(looks.missing)) or 'none'))
    L.append('== Liquid floors (BD SPLASH.acs BD_CheckIfOverLiquid): %s' % (
        '; '.join('%s: %s' % (k, ' '.join(v)) for k, v in sorted(flats.items())) or 'NOT FOUND'))
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')
    return L
