#!/usr/bin/env python3
"""residue_gen.py -- RSQ Gore PHASE 2 generator: the residue (floor spots and pools, ceiling spots, drips, footprints,
boot smears). Design: design/GORE_SYSTEM_DESIGN.md sections 2.2, 2.3 (rows Ceiling blood, Drips, Floor spots and pools,
Boot smears), 5 and 7 (phase table row 2).

    python -I Gore/tools/residue_gen.py <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>

Reads both packs (read-only, straight from the zips, through decorate.py) and the class list of the categories phase 2
owns from generated/takeover_table.txt ("floor spot+pool", "ceiling", "drip", "smear"; written by gen_gore.py, read
only here). For every class it WALKS BD's own states (water / floor / liquid-token / ceiling contexts) and writes one
residue CARD: what BD's actor shows, when, where it must stand, what it leaves (smear zones, spots, drips) and what it
does over a liquid. Then it writes:

  zscript/rsqgo/residue_cards.zs   the cards (RSQGO_ResData.BuildCards) and one actor class per BD class,
                                   RSQGO_R_<BD class>, with BD's Translation, Scale, Alpha, RenderStyle and the exact
                                   model frames BD shows (labels V0..Vn)
  MODELDEF.residue                 BD's own MODELDEF blocks for each visible class, renamed to our class (MODELDEF
                                   matches the exact class: models.cpp FindModelFrameRaw), pointing at BD's model files
  TEXTURES.residue / ANIMDEFS.residue / GLDEFS.residue (nomipmap)   the drip particles' looks (BD's falling drip and its landing splash, per colour),
                                   on our own names RSQGO_RL<nn>_<kk> (an ANIMDEFS animation is global to its texture)
  graphics/rsqgo_res/RSQGRnnn.png  green, blue and alien drip frames, baked from BD's frames through BD's translation
                                   with doom2.wad's PLAYPAL (E:/DOOMWork/doom2.wad), exactly as phase 1 bakes its own
  generated/residue_summary.txt    what each class became, what stayed BD's and why, the model cover radii

Every pk3 file it writes is a NEW file: the phase 1 outputs (TEXTURES.txt, ANIMDEFS.txt, cards.zs) are never touched.
The engine reads every TEXTURES / ANIMDEFS / MODELDEF lump of a pk3, whatever its extension.

Deterministic: cards in table order, looks in first-use order, floats printed with fixed precision. Never hand-edit
its outputs; residue_lint.py checks they are current.
"""
import math
import os
import re
import struct
import sys
import zipfile
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import decorate   # noqa: E402  (read-only use)

GORE = os.path.dirname(HERE)
TABLE = os.path.join(GORE, 'generated', 'takeover_table.txt')
OUT_ZS = os.path.join(GORE, 'zscript', 'rsqgo', 'residue_cards.zs')
OUT_MODELDEF = os.path.join(GORE, 'MODELDEF.residue')
OUT_TEX = os.path.join(GORE, 'TEXTURES.residue')
OUT_ANIM = os.path.join(GORE, 'ANIMDEFS.residue')
OUT_GL = os.path.join(GORE, 'GLDEFS.residue')
OUT_SUM = os.path.join(GORE, 'generated', 'residue_summary.txt')
# Drips are NOT colour-baked any more (as phase 1 now does it): our textures are BD's untranslated frames and the
# VisualThinker that plays a drip carries BD's class Translation, so the engine palette-squashes it exactly as it does
# BD's actor, through the PLAYPAL the rotation really loads (an offline bake from doom2.wad cannot know a later pack's
# PLAYPAL). The folder stays ours and is kept empty (write_bakes removes what it did not write).
BAKE_DIR = os.path.join('graphics', 'rsqgo_res')
DOOM2_WAD = os.path.normpath(os.path.join(GORE, '..', '..', 'doom2.wad'))

PHASE2 = ('floor spot+pool', 'ceiling', 'drip', 'smear')
INVISIBLE = ('TNT1', 'NULL')

# Card kinds (residue.zs RSQGO_ResData.RK_*)
RK_FLOOR, RK_CEIL, RK_LAUNCH, RK_DRIPPER, RK_DRIP, RK_SMEAR = range(6)
KIND_NAMES = ('floor', 'ceiling', 'launcher', 'drip spawner', 'drip', 'smearer')
# Where a floor card must stand (residue_data.zs ST_*): BD's A_CheckFloor removes a spot that is not on the floor after
# its check tic (the engine clips anything within 2 units onto the floor first); a gravity missile that explodes on
# landing (the growing pools) lives only when it spawns exactly on its floor with no velocity, since any P_ZMovement
# at all ends in P_ExplodeMissile; a plain actor with gravity falls to the floor and stays.
FS_SNAP, FS_VANISH, FS_MISSILE = 0, 1, 2
STAND_NAMES = ('snap', 'vanish', 'missile')
# Liquid bits, from BD's BD_CheckIfOverLiquid (SPLASH.acs): the token each floor texture gives.
LQ_BITS = {'isoverwater': 1, 'isoverslime': 2, 'isovernukage': 4, 'isoverlava': 8, 'isoverblood': 16}
# Colours (residue.zs C_*): from the translation, as cards.py's tint_of reads it.
COLOURS = ('red', 'green', 'blue', 'alien')

# Particles (drips): the same conventions as cards.py (a copy, so this tool never depends on a file another lane edits).
QUAD_K = 7.0 / 5.0 * math.sqrt(1.2)       # cards.py QUAD_K: size = canvas texels x scale x K
# The md3 flats BD's spots use are unit quads (models/bloodspot/*.md3 frame bounds, read below); a spot's visible blood
# covers about this share of its quad's half-width (the splat textures have soft, empty borders). The merge grid only
# counts a new spot as covered when it lies inside this radius, so the cut is conservative.
COVER_SHARE = 0.6


# ------------------------------------------------------------------ small parsers (state actions)
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
    out = []
    for m in CALL_RE.finditer(action or ''):
        if m.group(1).lower() in ('random', 'frandom'):
            continue
        j = decorate.match_brace(action, m.end() - 1, '(', ')')
        out.append((m.group(1), split_args(action[m.end():j])))
    if not out and action and re.match(r'^[A-Za-z_]\w*$', action.strip()):
        out.append((action.strip(), []))
    return out


def unq(s):
    return (s or '').strip().strip('"')


def rng(expr, default=(0.0, 0.0)):
    if expr is None or expr.strip() == '':
        return default
    e = expr.strip()
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


# ------------------------------------------------------------------ the walker
class Ctx:
    """One context a class is walked in: under water, on the floor, the liquid token BD's ACS gives, on a ceiling."""
    def __init__(self, water=False, floor=True, token=None, ceil=True):
        self.water, self.floor, self.token, self.ceil = water, floor, token, ceil


def _resolve_label(world, key, label):
    r = world.find_label(key, label)
    if r is None:
        return None
    k, ref = r
    if ref[0] == 'flow':
        return ('flow', ref[1])
    return (k, ref[1])


def _next(world, definer, idx):
    st = world.cls[definer].states
    nx = st.nxt[idx]
    if nx[0] == 'seq':
        if idx + 1 < len(st.S):
            return (definer, idx + 1)
        return ('flow', ('stop',))
    if nx[0] == 'loop':
        return ('loopto', definer, nx[1])
    if nx[0] == 'goto':
        g = world.goto(definer, nx[1])
        if g is None:
            return ('flow', ('stop',))
        if g[0] == 'flow':
            return ('flow', g[2])
        return g
    if nx[0] == 'wait':
        return ('loopto', definer, idx)
    return ('flow', ('stop',))


WATER_RE = re.compile(r'^\s*waterlevel\s*(<=|>=|==|!=|<|>)\s*(\d+)\s*$', re.I)


def water_taken(cond, water):
    """An A_JumpIf(waterlevel <op> n) at waterlevel 3 (under water) or 0 (dry land); None if not that form. A copy of
    phase 1's cards.py water_taken, so this tool never depends on a file another lane edits."""
    m = WATER_RE.match(cond)
    if not m:
        return None
    wl, op, n = (3 if water else 0), m.group(1), int(m.group(2))
    return {'<': wl < n, '>': wl > n, '<=': wl <= n, '>=': wl >= n, '==': wl == n, '!=': wl != n}[op]


def walk(world, key, label, ctx, limit=6000):
    """Every path through `label` for class `key`. Returns [{'w', 'ev', 'end'}]:
    ev: (t, 'show', spr, fr, tics) | (t, 'call', name, args) | (t, 'acs', script)
    end: ('stop', t) | ('park', t, spr, fr) | ('loop', t, period) | ('none',).
    Walking 'Spawn' is walking a freshly spawned actor: the engine never calls its first state's action unless that
    state is NoDelay (AActor::Tick only advances with SetState(next); CheckNoDelay), so that action is skipped (BD's
    `TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash")` first lines never run)."""
    start = _resolve_label(world, key, label)
    if start is None:
        return []
    out = []
    skip_first = None
    if label.lower() == 'spawn' and start[0] != 'flow':
        st0 = world.cls[start[0]].states.S[start[1]]
        if not st0.get('nodelay'):
            skip_first = start

    def run(pos, t, w, ev, acs, guard, seen):
        while True:
            if guard > limit or t > limit:
                out.append({'w': w, 'ev': ev, 'end': ('loop', t, 0)})
                return
            guard += 1
            if pos[0] == 'flow':
                f = pos[1]
                out.append({'w': w, 'ev': ev, 'end': ('stop', t)})
                return
            if pos[0] == 'loopto':
                # a loop ends the walk: BD's residue loops only to hold a frame (a drip's 500-tic fall, a ceiling
                # spot's thrust); walking it again would re-roll its jumps
                d, i = pos[1], pos[2]
                if ctx.water and skip_first is not None and (d, i) == skip_first and ('rerun',) not in seen:
                    # a loop back to the first Spawn state re-enters it through SetState: its action runs this time
                    # (BD's drip: `TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash")`, `BLUD Z 4`, `loop` tests the water
                    # every 4 tics, never on the spawn tic). Only the under-water walk takes it: on dry land the loop
                    # only holds a frame, and walking it again would re-roll its A_Jumps)
                    seen = dict(seen); seen[('rerun',)] = t
                    pos = (d, i)
                    continue
                out.append({'w': w, 'ev': ev, 'end': ('loop', t, t - seen.get((d, i), t))})
                return
            definer, idx = pos
            if (definer, idx) not in seen:
                seen = dict(seen); seen[(definer, idx)] = t
            stt = world.cls[definer].states.S[idx]
            tics = stt['tics'][0]
            jumped = None
            action = stt['action']
            if skip_first is not None and pos == skip_first and t == 0 and guard == 1:
                action = ''
            for name, args in calls_in(action):
                nl = name.lower()
                if nl not in ('acs_namedexecutealways', 'acs_namedexecute'):
                    ev = ev + [(t, 'call', name, args)]
                if nl == 'acs_namedexecutealways' or nl == 'acs_namedexecute':
                    ev = ev + [(t, 'acs', unq(args[0]) if args else '')]
                    if args and unq(args[0]).lower() == 'bd_checkifoverliquid':
                        acs = True
                    continue
                if nl == 'a_jumpif':
                    cond = args[0].lower() if args else ''
                    take = water_taken(cond, ctx.water)
                    if take is None:
                        take = ctx.water if 'waterlevel' in cond else False
                    if take and len(args) > 1:
                        jumped = [(1.0, unq(args[1]))]
                    continue
                if nl == 'a_checkfloor':
                    if ctx.floor and args:
                        jumped = [(1.0, unq(args[0]))]
                    continue
                if nl == 'a_checkceiling':
                    if ctx.ceil and args:
                        jumped = [(1.0, unq(args[0]))]
                    continue
                if nl == 'a_jumpifinventory':
                    item = unq(args[0]).lower() if args else ''
                    if acs and ctx.token and item == ctx.token and len(args) > 2:
                        jumped = [(1.0, unq(args[2]))]
                    continue
                if nl == 'a_jump':
                    ch = fnum(args[0], 0) if args else 0
                    labels = [unq(a) for a in args[1:]]
                    if labels and ch > 0:
                        p = min(256.0, ch) / 256.0
                        jumped = [(p / len(labels), lb) for lb in labels]
                        if p < 1.0:
                            jumped.append((1.0 - p, None))
                    continue
                if nl == 'a_die':
                    typ = unq(args[0]) if args else ''
                    lb = 'death.' + typ if typ and world.find_label(key, 'death.' + typ) else 'death'
                    jumped = [(1.0, lb)]
                    continue
            if jumped:
                for p, lb in jumped:
                    if lb is None:
                        nxt = _next(world, definer, idx)
                        # a jump that is not taken: this state still plays its tics
                        ev2 = ev
                        if stt['sprite'] not in INVISIBLE and tics != 0:
                            ev2 = ev + [(t, 'show', stt['sprite'], stt['frame'], tics)]
                        if tics < 0:
                            out.append({'w': w * p, 'ev': ev2, 'end': ('park', t, stt['sprite'], stt['frame'])})
                            continue
                        run(nxt, t + tics, w * p, ev2, acs, guard, seen)
                    else:
                        tgt = _resolve_label(world, key, lb)
                        if tgt is None:
                            # a jump to a label the class lacks: the engine sets a null state, which removes it
                            out.append({'w': w * p, 'ev': ev, 'end': ('stop', t)})
                            continue
                        run(tgt, t, w * p, ev, acs, guard, seen)
                return
            if stt['sprite'] not in INVISIBLE and tics != 0:
                ev = ev + [(t, 'show', stt['sprite'], stt['frame'], tics)]
            if tics < 0:
                out.append({'w': w, 'ev': ev, 'end': ('park', t, stt['sprite'], stt['frame'])})
                return
            pos = _next(world, definer, idx)
            t += tics

    run(start, 0, 1.0, [], False, 0, {})
    return out


def main_path(paths):
    """The heaviest path (BD's usual outcome)."""
    return max(paths, key=lambda p: p['w']) if paths else None


def spawns(ev):
    """[(t, func, class, args)] of a path's spawn calls."""
    out = []
    for e in ev:
        if e[1] == 'call' and e[2].lower() in ('a_spawnitemex', 'a_spawnitem', 'a_custommissile', 'a_spawnprojectile'):
            if e[3]:
                out.append((e[0], e[2], unq(e[3][0]), e[3]))
    return out


def calls(ev, name):
    return [e for e in ev if e[1] == 'call' and e[2].lower() == name]


def visible(path):
    """Did this path leave something on screen (a parked or looping visible frame)?"""
    end = path['end']
    if end[0] == 'park':
        return end[2] not in INVISIBLE
    if end[0] == 'loop':
        return any(e[1] == 'show' for e in path['ev'])
    return False


# ------------------------------------------------------------------ the pk3s: modeldef, sprites, md3 bounds, liquids
def read_modeldefs(pk3):
    """lower class -> [block text] from every MODELDEF lump of the pack (in path order)."""
    z = zipfile.ZipFile(pk3)
    out = {}
    for n in sorted(z.namelist()):
        base = n.replace('\\', '/').split('/')[-1]
        if '/' in n.replace('\\', '/').strip('/') or not base.lower().startswith('modeldef'):
            continue
        t = decorate.strip_comments(z.read(n).decode('latin-1'))
        for m in re.finditer(r'\bmodel\s+"?([\w]+)"?\s*\{', t, re.I):
            j = decorate.match_brace(t, m.end() - 1)
            body = t[m.end():j]
            out.setdefault(m.group(1).lower(), []).append(body)
    return out


def block_info(body):
    """(model file, xscale, frames [(spr, fr)]) of one MODELDEF block."""
    mf = re.search(r'\bmodel\s+\d+\s+"([^"]+)"', body, re.I)
    sc = re.search(r'\bscale\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)', body, re.I)
    frames = [(a.upper(), b.upper()) for a, b in re.findall(r'\bframeindex\s+(\w{4})\s+(\w)\s+\d+\s+\d+', body, re.I)]
    frames += [(a.upper(), b.upper()) for a, b in re.findall(r'\bframe\s+(\w{4})\s+(\w)\s+\d+\s+"', body, re.I)]
    return (mf.group(1).lower() if mf else None, abs(fnum(sc.group(1), 1.0)) if sc else 1.0, frames)


def md3_halfwidths(pk3):
    """lower md3 file name (no path) -> half of its first frame's xy extent."""
    z = zipfile.ZipFile(pk3)
    out = {}
    for n in z.namelist():
        if not n.lower().endswith('.md3'):
            continue
        d = z.read(n)
        if len(d) < 108 or d[:4] != b'IDP3':
            continue
        # header: ident(4) version(4) name(64) flags(4) | nframes ntags nsurfaces nskins ofs_frames
        nframes, ntags, nsurf, nskins, ofs_frames = struct.unpack('<5i', d[76:96])
        if nframes < 1 or ofs_frames <= 0 or ofs_frames + 24 > len(d):
            continue
        mn = struct.unpack('<3f', d[ofs_frames:ofs_frames + 12])
        mx = struct.unpack('<3f', d[ofs_frames + 12:ofs_frames + 24])
        out[n.replace('\\', '/').split('/')[-1].lower()] = max(mx[0] - mn[0], mx[1] - mn[1]) / 2.0
    return out


def read_sprite_info(data):
    """(w, h, xoff, yoff) of a PNG (IHDR + grAb) or a Doom patch, else None (cards.py's reader, copied)."""
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


def load_sprites(packs):
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
    for lump in (spr + fr + '0', spr + fr + '1'):
        if lump in sprites:
            return lump, False, sprites[lump]
    for lump, info in sorted(sprites.items()):
        if lump.startswith(spr) and len(lump) == 8 and lump[6:8] in (fr + '0', fr + '1'):
            return lump, True, info
    return None, False, None


def liquid_flats(packs):
    """BD's BD_CheckIfOverLiquid (SPLASH.acs): [(FLAT, bit)] in script order."""
    for path, _ in packs:
        z = zipfile.ZipFile(path)
        for n in sorted(z.namelist()):
            if n.lower().endswith('splash.acs'):
                t = z.read(n).decode('latin-1')
                m = re.search(r'script\s+"BD_CheckIfOverLiquid".*?\{(.*?)\n\}', t, re.S | re.I)
                if not m:
                    continue
                out = []
                for flat, inv in re.findall(r'CheckActorFloorTexture\s*\(\s*0\s*,\s*"(\w+)"\s*\)\s*\)\s*\{\s*'
                                            r'GiveInventory\s*\(\s*"(\w+)"', m.group(1), re.I):
                    if inv.lower() in LQ_BITS:
                        out.append((flat.upper(), LQ_BITS[inv.lower()]))
                if out:
                    return out
    return []


def colour_of(trans):
    if not trans:
        return 0
    t = trans.lower()
    if '119,81,140' in t.replace(' ', '') or '172,118,204' in t.replace(' ', ''):
        return 3
    m = re.search(r'=\s*(\d+)\s*:', t)
    if m:
        v = int(m.group(1))
        if 112 <= v <= 127:
            return 1
        if 192 <= v <= 207:
            return 2
    return 0


def trans_key(trans):
    """A translation string, spelled one way (spaces dropped): the same translation shares its looks and bakes."""
    return re.sub(r'\s+', '', trans) if trans else ''


# ------------------------------------------------------------------ the colour bake (a copy of phase 1's, cards.py)
# THE BAKE, as the engine applies a translation (palettecontainer.cpp FRemapTable::AddIndexRange / AddColorRange;
# palette.cpp BestColor): every texel is matched to its nearest PLAYPAL index (1-254, squared RGB distance), that index
# goes through BD's translation, other indices keep their colour, and each texel keeps its own alpha. Copied rather
# than imported so this tool never breaks when phase 1's generator changes.
def read_playpal(wad):
    with open(wad, 'rb') as fh:
        data = fh.read()
    n, off = struct.unpack('<ii', data[4:12])
    for k in range(n):
        pos, size, name = struct.unpack('<ii8s', data[off + 16 * k:off + 16 * k + 16])
        if name.rstrip(b'\0').upper() == b'PLAYPAL':
            raw = data[pos:pos + 768]
            return [tuple(raw[3 * i:3 * i + 3]) for i in range(256)]
    raise ValueError('no PLAYPAL in ' + wad)


def translation_palette(trans, pal):
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


class Matcher:
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


def decode_png(data):
    """(w, h, [(r, g, b, a)...]) for a non-interlaced PNG (8-bit grey/RGB/GA/RGBA, 1-8-bit palette or grey)."""
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
    fbpp = bpp if depth == 8 else 1
    prev = bytearray(stride)
    out = []
    pos = 0
    for _ in range(h):
        ft = raw[pos]
        pos += 1
        line = bytearray(raw[pos:pos + stride])
        pos += stride
        for x in range(stride):
            a = line[x - fbpp] if x >= fbpp else 0
            b = prev[x]
            c = prev[x - fbpp] if x >= fbpp else 0
            if ft == 1:
                line[x] = (line[x] + a) & 255
            elif ft == 2:
                line[x] = (line[x] + b) & 255
            elif ft == 3:
                line[x] = (line[x] + ((a + b) >> 1)) & 255
            elif ft == 4:
                pp = a + b - c
                pa, pb, pc = abs(pp - a), abs(pp - b), abs(pp - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 255
        if depth != 8:
            per, mask = 8 // depth, (1 << depth) - 1
            for x in range(w):
                v = (line[x // per] >> (8 - depth * (x % per + 1))) & mask
                if ct == 3:
                    r, g, b = pal[v] if pal and v < len(pal) else (0, 0, 0)
                    out.append((r, g, b, trns[v] if trns and v < len(trns) else 255))
                else:
                    gv = v * 255 // mask
                    out.append((gv, gv, gv, 255))
            prev = line
            continue
        for x in range(w):
            sm = line[x * bpp:(x + 1) * bpp]
            if ct == 6:
                out.append(tuple(sm))
            elif ct == 2:
                out.append((sm[0], sm[1], sm[2], 255))
            elif ct == 3:
                r, g, b = pal[sm[0]] if pal and sm[0] < len(pal) else (0, 0, 0)
                out.append((r, g, b, trns[sm[0]] if trns and sm[0] < len(trns) else 255))
            elif ct == 0:
                out.append((sm[0], sm[0], sm[0], 255))
            else:
                out.append((sm[0], sm[0], sm[0], sm[1]))
        prev = line
    return w, h, out


def decode_patch(data):
    """(w, h, [palette index or -1]) for a Doom patch, else None."""
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
            top = row if row > top else top + row
            ln = data[col + 1]
            for k in range(ln):
                y = top + k
                if 0 <= y < h and col + 3 + k < len(data):
                    px[y * w + x] = data[col + 3 + k]
            col += ln + 4
    return w, h, px


def png_bytes(w, h, rgba, xoff, yoff):
    """An RGBA PNG with a grAb chunk, filter 0, zlib level 9: the same bytes every run."""
    def chunk(typ, body):
        return struct.pack('>I', len(body)) + typ + body + struct.pack('>I', zlib.crc32(typ + body) & 0xFFFFFFFF)
    rows = bytearray()
    for y in range(h):
        rows.append(0)
        for (r, g, b, a) in rgba[y * w:(y + 1) * w]:
            rows += bytes((r, g, b, a))
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)) +
            chunk(b'grAb', struct.pack('>ii', xoff, yoff)) + chunk(b'IDAT', zlib.compress(bytes(rows), 9)) +
            chunk(b'IEND', b''))


def bake_name(n):
    """RSQGR + 3 base-36 digits: 8 characters, unique as a lump short name (phase 1 uses RSQGO + 3)."""
    digits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    t = ''
    for _ in range(3):
        t = digits[n % 36] + t
        n //= 36
    return 'RSQGR' + t


def plan_bakes(looks):
    """No colour bakes: the translation is applied at run time (see BAKE_DIR)."""
    return {}


def make_bakes(looks, packs, wad):
    """(plan, {baked lump name: PNG bytes}) for every coloured drip frame."""
    plan = plan_bakes(looks)
    if not plan:
        return plan, {}
    pal = read_playpal(wad)
    match = Matcher(pal)
    raw = {}
    for path, _ in packs:
        z = zipfile.ZipFile(path)
        for n in z.namelist():
            ln = n.replace('\\', '/').lower()
            if ln.startswith('sprites/') and not ln.endswith('/'):
                raw[n.split('/')[-1].split('.')[0].upper()] = (path, n)
    trans_of = {trans_key(lk['trans']): lk['trans'] for lk in looks.list if lk['trans']}
    tpal = {k: translation_palette(v, pal) for k, v in trans_of.items()}
    decoded, out = {}, {}
    for (lump, tk), name in sorted(plan.items(), key=lambda kv: kv[1]):
        if lump not in decoded:
            path, n = raw[lump]
            data = zipfile.ZipFile(path).read(n)
            info = read_sprite_info(data[:4096])
            png = decode_png(data)
            if png:
                w, h, pix = png
                idx = [(match.pick((r, g, b)) if a else -1, a) for (r, g, b, a) in pix]
            else:
                pt = decode_patch(data)
                if pt is None:
                    raise ValueError('cannot decode sprite %s for baking' % lump)
                w, h, px = pt
                idx = [(i, 255 if i >= 0 else 0) for i in px]
            decoded[lump] = (w, h, idx, info)
        w, h, idx, info = decoded[lump]
        tp = tpal[tk]
        rgba = [(tp[i] + (a,)) if i >= 0 and a else (0, 0, 0, 0) for (i, a) in idx]
        out[name] = png_bytes(w, h, rgba, info[2], info[3])
    return plan, out


def write_bakes(bakes, root):
    """Writes the baked PNGs under root/BAKE_DIR; the folder is ours, so files we did not bake are removed."""
    folder = os.path.join(root, BAKE_DIR)
    os.makedirs(folder, exist_ok=True)
    keep = {k + '.png' for k in bakes}
    for fn in os.listdir(folder):
        if fn not in keep:
            os.remove(os.path.join(folder, fn))
    for k, data in sorted(bakes.items()):
        with open(os.path.join(folder, k + '.png'), 'wb') as fh:
            fh.write(data)


# ------------------------------------------------------------------ cards
def scale_of(world, key):
    s = world.pval(key, 'scale')
    sx = world.pval(key, 'xscale', s)
    sy = world.pval(key, 'yscale', s)
    return fnum(sx, 1.0), fnum(sy, 1.0)


def rstyle(world, key):
    v = (world.pval(key, 'renderstyle', 'normal') or 'normal').lower()
    return {'normal': 'Normal', 'translucent': 'Translucent', 'add': 'Add', 'shaded': 'Shaded',
            'none': 'None', 'stencil': 'Stencil', 'subtract': 'Subtract'}.get(v, 'Normal')


def liquid_outcome(world, key, label, base_end_visible):
    """For each liquid bit: what the class does when BD's ACS reports that liquid. Returns (mask, action, class):
    action 0 = vanish, 1 = leave `class` (BD's WaterBloodSpot) instead."""
    mask, act, cls = 0, 0, ''
    for tok, bit in LQ_BITS.items():
        ps = walk(world, key, label, Ctx(token=tok))
        p = main_path(ps)
        if not p:
            continue
        if visible(p) and base_end_visible:
            continue
        mask |= bit
        sp = [s for s in spawns(p['ev'])]
        if sp:
            act, cls = 1, sp[0][2]
    return mask, act, cls


class Card:
    def __init__(self, name, kind):
        self.name, self.kind = name, kind
        self.why = ''
        self.d = {}


def floor_card(world, key, md, md3w):
    a = world.cls[key]
    c = Card(a.name, RK_FLOOR)
    paths = walk(world, key, 'Spawn', Ctx())
    if not paths:
        return None, 'no Spawn states'
    vis = [p for p in paths if visible(p)]
    if not vis:
        return None, 'shows nothing on the floor'
    tw = sum(p['w'] for p in vis)
    frames = {}
    show_t = None
    for p in vis:
        end = p['end']
        if end[0] == 'park':
            fr = (end[2], end[3])
        else:
            sh = [e for e in p['ev'] if e[1] == 'show']
            fr = (sh[-1][2], sh[-1][3])
        frames[fr] = frames.get(fr, 0.0) + p['w'] / tw
        st = min([e[0] for e in p['ev'] if e[1] == 'show'] + ([end[1]] if end[0] == 'park' else []))
        show_t = st if show_t is None else min(show_t, st)
    p0 = main_path(vis)
    ev = p0['ev']
    sx, sy = scale_of(world, key)
    ramp = []
    for e in calls(ev, 'a_setscale'):
        v = fnum(e[3][0], None) if e[3] else None
        if v is not None:
            ramp.append((e[0], v))
    smear_t, smear_cls = -1, ''
    for t, fn, cl, args in spawns(ev):
        if cl.lower().startswith('bootsmearer'):
            smear_t, smear_cls = t, cl
    face = bool(calls(ev, 'a_facetarget'))
    queued = bool(calls(ev, 'a_queuecorpse'))
    acs = any(e[1] == 'acs' and e[2].lower() == 'bd_checkifoverliquid' for e in ev)
    acs_t = min([e[0] for e in ev if e[1] == 'acs'], default=0)
    # liquid tokens: checked at the tic after BD's wait (the first tic a token jump could be taken)
    lmask, lact, lcls = liquid_outcome(world, key, 'Spawn', True) if acs else (0, 0, '')
    # the floor: A_CheckFloor (off the floor -> gone), or a gravity missile (explodes on landing unless its Death
    # label plays the same states: the footprints alias Spawn/Death/Crash)
    off = main_path(walk(world, key, 'Spawn', Ctx(floor=False)))
    fl = world.flags(key)
    uses_check = any(e[1] == 'call' and e[2].lower() == 'a_checkfloor' for p in paths for e in p['ev'])
    check_t = min([e[0] for p in paths for e in p['ev'] if e[1] == 'call' and e[2].lower() == 'a_checkfloor'], default=0)
    if uses_check:
        stand = FS_SNAP if (off and visible(off)) else FS_VANISH
    elif fl.get('missile') and not fl.get('nogravity'):
        dl = world.find_label(key, 'death')
        sl = world.find_label(key, 'spawn')
        explodes = not (fl.get('noexplodefloor') or fl.get('floorhugger') or fl.get('_bounce') or fl.get('bounceonfloors'))
        stand = FS_SNAP if (dl and sl and dl == sl) or not explodes else FS_MISSILE
        check_t = 0
    else:
        stand = FS_SNAP
    water = main_path(walk(world, key, 'Spawn', Ctx(water=True)))
    water_vanish = not (water and visible(water))
    # model frames and cover radius
    blocks = md.get(key, [])
    frame_scale = {}
    for b in blocks:
        mfile, xs, frs = block_info(b)
        hw = md3w.get((mfile or '').split('/')[-1], 1.0)
        for fr in frs:
            frame_scale[fr] = max(frame_scale.get(fr, 0.0), xs * hw)
    final = ramp[-1][1] if ramp else sx
    radii = [frame_scale.get(fr, 0.0) * abs(final) for fr in frames]
    rq_lo = min(radii) if radii else 0.0
    rq_hi = max(radii) if radii else 0.0
    name_l = key
    sub = 'pool' if ramp else ('footprint' if 'footprint' in name_l else 'spot')
    c.d = dict(frames=sorted(frames.items()), show_t=show_t, scale=(sx, sy), ramp=ramp, smear_t=smear_t,
               smear_cls=smear_cls, face=face, queued=queued, acs_t=acs_t, check_t=check_t, lmask=lmask, lact=lact,
               lcls=lcls, stand=stand, water_vanish=water_vanish, alpha=fnum(world.pval(key, 'alpha'), 1.0),
               style=rstyle(world, key), trans=world.prop(key, 'translation'), sub=sub,
               cover_lo=rq_lo * COVER_SHARE, cover_hi=rq_hi * COVER_SHARE, quad=rq_hi, blocks=len(blocks),
               height=fnum(world.prop(key, 'height'), 2.0), flags=fl, missile=bool(fl.get('missile')),
               uses_check=uses_check)
    if not blocks:
        c.why = 'no MODELDEF block: drawn as its sprite'
    return c, None


def ceil_card(world, key, md, md3w):
    a = world.cls[key]
    c = Card(a.name, RK_CEIL)
    paths = walk(world, key, 'Spawn', Ctx())
    p = main_path(paths)
    if not p:
        return None, 'no Spawn states'
    sh = [e for e in p['ev'] if e[1] == 'show']
    if not sh:
        return None, 'shows nothing'
    frames = sorted({(e[2], e[3]) for e in sh})
    if len(frames) != 1:
        return None, 'more than one frame on the ceiling (%s)' % frames
    sx, sy = scale_of(world, key)
    kids = [(t, cl, args) for t, fn, cl, args in spawns(p['ev'])]
    water = main_path(walk(world, key, 'Spawn', Ctx(water=True)))
    blocks = md.get(key, [])
    xs_hw = 0.0
    for b in blocks:
        mfile, xs, frs = block_info(b)
        xs_hw = max(xs_hw, xs * md3w.get((mfile or '').split('/')[-1], 1.0))
    c.d = dict(frames=[(frames[0], 1.0)], show_t=sh[0][0], scale=(sx, sy), kids=kids,
               water_vanish=not (water and visible(water)), alpha=fnum(world.pval(key, 'alpha'), 1.0),
               style=rstyle(world, key), trans=world.prop(key, 'translation'),
               cover_lo=xs_hw * abs(sx) * COVER_SHARE, cover_hi=xs_hw * abs(sx) * COVER_SHARE, quad=xs_hw * abs(sx),
               blocks=len(blocks), height=fnum(world.prop(key, 'height'), 1.0), flags=world.flags(key))
    return c, None


def launcher_card(world, key):
    a = world.cls[key]
    c = Card(a.name, RK_LAUNCH)
    p = main_path(walk(world, key, 'Spawn', Ctx()))
    if not p or p['end'][0] != 'stop':
        return None, 'its Spawn sequence does not end'
    life = p['end'][1]
    d = main_path(walk(world, key, 'Death', Ctx(ceil=True)))
    sp = spawns(d['ev']) if d else []
    if not sp:
        return None, 'its Death leaves nothing on a ceiling'
    nd = main_path(walk(world, key, 'Death', Ctx(ceil=False)))
    if nd and spawns(nd['ev']):
        return None, 'its Death spawns something off the ceiling too'
    water = main_path(walk(world, key, 'Spawn', Ctx(water=True)))
    fl = world.flags(key)
    # under water it is gone when its Spawn plays out differently there (a waterlevel jump that is really taken)
    water_vanish = not water or (water['ev'], water['end']) != (p['ev'], p['end'])
    c.d = dict(life=life, speed=fnum(world.pval(key, 'speed'), 0.0), grav=fnum(world.pval(key, 'gravity'), 1.0),
               spot=sp[0][2], spot_t=sp[0][0], bounce=bool(fl.get('bounceonwalls')),
               water_vanish=water_vanish)
    return c, None


def dripper_card(world, key):
    a = world.cls[key]
    c = Card(a.name, RK_DRIPPER)
    p = main_path(walk(world, key, 'Spawn', Ctx()))
    if not p or p['end'][0] != 'stop':
        return None, 'its Spawn sequence does not end'
    runs = []
    for t, fn, cl, args in spawns(p['ev']):
        if fn.lower() == 'a_spawnitemex':
            r = [rng(args[i] if i < len(args) else None) for i in range(1, 7)]
            if any(x is None for x in r):
                return None, 'a spawn argument it cannot evaluate: %s' % (args,)
            mode = 0
        elif fn.lower() == 'a_spawnitem':
            dist = rng(args[1] if len(args) > 1 else None)
            zh = rng(args[2] if len(args) > 2 else None)
            if dist is None or zh is None:
                return None, 'a spawn argument it cannot evaluate: %s' % (args,)
            r = [dist, (0.0, 0.0), zh, (0.0, 0.0), (0.0, 0.0), (0.0, 0.0)]
            mode = 1
        else:
            return None, 'spawns with %s' % fn
        sig = (cl.lower(), mode, tuple(r))
        if runs and runs[-1]['sig'] == sig and (runs[-1]['count'] == 1 or t - runs[-1]['last'] == runs[-1]['interval']):
            rr = runs[-1]
            if rr['count'] == 1:
                rr['interval'] = t - rr['last']
            rr['count'] += 1
            rr['last'] = t
        else:
            runs.append({'sig': sig, 'cls': cl, 'mode': mode, 'r': r, 't': t, 'count': 1, 'interval': 0, 'last': t})
    c.d = dict(life=p['end'][1], runs=runs)
    return c, None


def drip_card(world, key, sprites):
    a = world.cls[key]
    c = Card(a.name, RK_DRIP)
    paths = walk(world, key, 'Spawn', Ctx())
    vis = [p for p in paths if visible(p)]
    if not vis:
        return None, 'never shows'
    keep = sum(p['w'] for p in vis)
    p = main_path(vis)
    sh = [e for e in p['ev'] if e[1] == 'show']
    look = (sh[-1][2], sh[-1][3])
    wkids = []
    for wp in walk(world, key, 'Spawn', Ctx(water=True)):
        for t, fn, cl, args in spawns(wp['ev']):
            if cl not in wkids:
                wkids.append(cl)
    d = main_path(walk(world, key, 'Death', Ctx()))
    if not d:
        return None, 'no Death states'
    spot = ''
    for t, fn, cl, args in spawns(d['ev']):
        spot = cl
    snd = ''
    for e in calls(d['ev'], 'a_playsound') + calls(d['ev'], 'a_startsound'):
        snd = unq(e[3][0]) if e[3] else ''
    splash = [(e[2], e[3], e[4]) for e in d['ev'] if e[1] == 'show']
    sx, sy = scale_of(world, key)
    c.d = dict(keep=keep, look=look, water_kids=wkids, spot=spot, sound=snd, splash=splash, scale=(sx, sy),
               alpha=fnum(world.pval(key, 'alpha'), 1.0), grav=fnum(world.pval(key, 'gravity'), 1.0),
               trans=world.prop(key, 'translation'), style=rstyle(world, key))
    return c, None


def smear_card(world, key):
    a = world.cls[key]
    c = Card(a.name, RK_SMEAR)
    p = main_path(walk(world, key, 'Spawn', Ctx()))
    if not p:
        return None, 'no Spawn states'
    look = calls(p['ev'], 'a_look')
    chk = calls(p['ev'], 'a_jumpifcloser')
    if not look or not chk:
        return None, 'not BD\'s look-then-check smearer shape'
    tics = [e[0] for e in chk]
    period = tics[1] - tics[0] if len(tics) > 1 else 8
    if any(tics[i + 1] - tics[i] != period for i in range(len(tics) - 1)):
        return None, 'irregular check spacing'
    dist = fnum(chk[0][3][0], 60.0)
    target = unq(chk[0][3][1]) if len(chk[0][3]) > 1 else ''
    g = main_path(walk(world, key, target, Ctx())) if target else None
    give = calls(g['ev'], 'a_givetotarget') if g else []
    if not give:
        return None, 'its check gives nothing'
    item = unq(give[0][3][0])
    amount = int(fnum(give[0][3][1], 1)) if len(give[0][3]) > 1 else 1
    # the A_Chase tics between a lock and the first check (BD: See = A_Chase x N, then A_Die runs the first check)
    chase = len(calls(p['ev'], 'a_chase'))
    c.d = dict(look_t=look[0][0], first=tics[0], period=period, count=len(tics), end=p['end'][1] if p['end'][0] == 'stop' else 0,
               dist=dist, item=item, amount=amount, noz=False, chase=chase)
    return c, None


# ------------------------------------------------------------------ looks (drip particles)
class Looks:
    def __init__(self, sprites):
        self.sprites = sprites
        self.keys = {}
        self.list = []
        self.missing = set()

    def get(self, trans, frames, aspect):
        """frames [(spr, fr, tics)]. One look per frame list: the colour comes from the class Translation at run time
        and the scale from the card, so neither keys a look (trans and aspect are kept for the summary only)."""
        key = tuple(frames)
        if key in self.keys:
            return self.keys[key]
        fl = []
        for spr, fr, tics in frames:
            lump, flipped, info = frame_lump(self.sprites, spr, fr)
            if lump is None:
                self.missing.add(spr + fr)
                self.keys[key] = None
                return None
            fl.append((lump, flipped, tics, info))
        half = 1
        for lump, flipped, tics, (w, h, xo, yo) in fl:
            half = max(half, abs(xo), abs(w - xo), abs(yo), abs(h - yo))
        canvas = min(2048, 2 * half)
        idx = len(self.list)
        name = 'RSQGO_RL%02d' % idx
        self.list.append({'name': name, 'frames': fl, 'trans': '', 'canvas': canvas, 'aspect': 1.0,
                          'tex': ['%s_%02d' % (name, k) for k in range(len(fl))]})
        self.keys[key] = idx
        return idx


def f(x, nd=4):
    s = ('%.' + str(nd) + 'f') % x
    s = s.rstrip('0').rstrip('.') if '.' in s else s
    return '0' if s in ('-0', '') else s


def zstr(s):
    return '"%s"' % (s or '').replace('"', '')


# ------------------------------------------------------------------ build
def read_table():
    rows = []
    with open(TABLE, encoding='utf-8') as fh:
        for ln in fh:
            if ln.startswith('#') or ln.startswith('class\t'):
                continue
            p = ln.rstrip('\n').split('\t')
            if len(p) > 3 and p[1] in PHASE2:
                rows.append({'class': p[0], 'cat': p[1], 'owner': p[3]})
    return rows


def build(packs):
    world = decorate.World(packs)
    rows = read_table()
    md = read_modeldefs(packs[0][0])
    md3w = md3_halfwidths(packs[0][0])
    sprites = load_sprites(packs)
    flats = liquid_flats(packs)
    cards, left = [], []
    for r in rows:
        key = r['class'].lower()
        if key not in world.cls:
            left.append((r['class'], 'not in the packs'))
            continue
        a = world.cls[key]
        fl = world.flags(key)
        cat = r['cat']
        res = (None, None)
        if cat == 'floor spot+pool':
            if fl.get('nointeraction') and world.engine_parent(key) and 'token' in (a.parent or '').lower():
                res = (None, 'an inventory token (BD gives it to the player to alternate left and right prints), not a '
                             'spot: taking it over would break BD\'s footprints')
            elif (a.parent or '').lower() == 'bd_token':
                res = (None, 'an inventory token (BD gives it to the player to alternate left and right prints), not a '
                             'spot: taking it over would break BD\'s footprints')
            else:
                res = floor_card(world, key, md, md3w)
        elif cat == 'ceiling':
            if 'launcher' in key:
                res = launcher_card(world, key)
            else:
                res = ceil_card(world, key, md, md3w)
        elif cat == 'drip':
            if 'spawner' in key:
                res = dripper_card(world, key)
            else:
                res = drip_card(world, key, sprites)
        elif cat == 'smear':
            res = smear_card(world, key)
        c, why = res
        if c is None:
            left.append((r['class'], why))
        else:
            cards.append(c)
    # every class a card names must be a card or exist (a drip's spot, a launcher's spot, a spawner's drip)
    idx = {c.name.lower(): i for i, c in enumerate(cards)}
    for c in cards:
        refs = []
        if c.kind == RK_FLOOR and c.d['smear_cls']:
            refs.append(c.d['smear_cls'])
        if c.kind == RK_CEIL:
            refs += [k[1] for k in c.d['kids']]
        if c.kind == RK_LAUNCH:
            refs.append(c.d['spot'])
        if c.kind == RK_DRIPPER:
            refs += [rr['cls'] for rr in c.d['runs']]
        if c.kind == RK_DRIP and c.d['spot']:
            refs.append(c.d['spot'])
        c.refs = refs
        c.unresolved = [x for x in refs if x.lower() not in idx]
    # drip looks
    looks = Looks(sprites)
    for c in cards:
        if c.kind != RK_DRIP:
            continue
        sx, sy = c.d['scale']
        asp = abs(sx) / abs(sy) if sy else 1.0
        spr, fr = c.d['look']
        c.d['look_fall'] = looks.get(c.d['trans'], [(spr, fr, 1)], asp)
        sp = c.d['splash']
        c.d['look_splash'] = looks.get(c.d['trans'], [(s, ff, t) for s, ff, t in sp], 1.0) if sp else None
        c.d['splash_life'] = sum(t for s, ff, t in sp)
    return world, cards, left, looks, flats, md, idx


def zs_class(name):
    return 'RSQGO_R_' + name


# BD's render style name (rstyle) -> the ZScript ERenderStyle constant a VisualThinker takes
STYLE_CONST = {'Normal': 'STYLE_Normal', 'Translucent': 'STYLE_Translucent', 'Add': 'STYLE_Add', 'Shaded': 'STYLE_Shaded',
               'None': 'STYLE_None', 'Stencil': 'STYLE_Stencil', 'Subtract': 'STYLE_Subtract'}


def write_zs(cards, looks, flats, idx, path, bd_name):
    L = ['// ============================================================================',
         '// RSQ Gore residue cards -- GENERATED by Gore/tools/residue_gen.py from %s. Never hand-edit.' % bd_name,
         '// One card per Brutal Doom residue class (floor spots, pools, footprints, ceiling spots and launchers, drip',
         '// spawners, drips, boot smearers), walked from BD\'s own states; and one actor class per BD class, RSQGO_R_<name>,',
         '// that the takeover spawns instead (residue.zs RSQGO_ResidueRings.TakeOver). Visible classes carry BD\'s Translation,',
         '// Scale, Alpha and RenderStyle and one label per model frame BD shows (V0..Vn): MODELDEF.residue gives each the',
         '// exact BD model blocks (MODELDEF matches the exact class).',
         '// ============================================================================',
         '',
         'extend class RSQGO_ResData',
         '{',
         '\tvoid BuildCards()',
         '\t{']
    for flat, bit in flats:
        L.append('\t\tAddLiquid("%s", %d);' % (flat, bit))
    for lk in looks.list:
        L.append('\t\tAddLook();')
        for (lump, flipped, tics, info), name in zip(lk['frames'], lk['tex']):
            L.append('\t\tAddLookFrame("%s", %d);' % (name, max(1, tics)))
    for i, c in enumerate(cards):
        d = c.d
        if c.kind == RK_FLOOR:
            sub = {'spot': 0, 'pool': 1, 'footprint': 2}[d['sub']]
            L.append('\t\tAddFloor("%s", %d, %d, %s, %s, %d, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s);  // %d' % (
                c.name, sub, colour_of(d['trans']), f(abs(d['scale'][0])), f(d['alpha'], 3), d['show_t'],
                d['stand'], d['check_t'], d['lmask'], d['acs_t'], d['lact'], d['smear_t'],
                zstr(d['smear_cls']), zstr(d['lcls']), 'true' if d['face'] else 'false',
                f(d['cover_lo'], 2), f(d['cover_hi'], 2), 'true' if d['water_vanish'] else 'false',
                'true' if d['missile'] else 'false', i))
            for (spr, fr), w in d['frames']:
                L.append('\t\tAddFrame(%s);   // %s%s' % (f(w, 5), spr, fr))
            for t, s in d['ramp']:
                L.append('\t\tAddRamp(%d, %s);' % (t, f(s, 3)))
        elif c.kind == RK_CEIL:
            L.append('\t\tAddCeil("%s", %d, %s, %s, %d, %s, %s, %s);  // %d' % (
                c.name, colour_of(d['trans']), f(abs(d['scale'][0])), f(d['alpha'], 3), d['show_t'],
                f(d['cover_lo'], 2), f(d['cover_hi'], 2), 'true' if d['water_vanish'] else 'false', i))
            for (spr, fr), w in d['frames']:
                L.append('\t\tAddFrame(%s);   // %s%s' % (f(w, 5), spr, fr))
            for t, cl, args in d['kids']:
                L.append('\t\tAddKid(%d, "%s");' % (t, cl))
        elif c.kind == RK_LAUNCH:
            L.append('\t\tAddLauncher("%s", %d, %s, %s, "%s", %d, %s, %s);  // %d' % (
                c.name, d['life'], f(d['speed']), f(d['grav']), d['spot'], d['spot_t'],
                'true' if d['bounce'] else 'false', 'true' if d['water_vanish'] else 'false', i))
        elif c.kind == RK_DRIPPER:
            L.append('\t\tAddDripper("%s", %d);  // %d' % (c.name, d['life'], i))
            for rr in d['runs']:
                r = rr['r']
                L.append('\t\tAddRun("%s", %d, %d, %d, %d, %s);' % (
                    rr['cls'], rr['mode'], rr['t'], rr['count'], rr['interval'],
                    ', '.join(f(v) for pair in r for v in pair)))
        elif c.kind == RK_DRIP:
            sx, sy = d['scale']
            lf = d['look_fall'] if d['look_fall'] is not None else -1
            ls = d['look_splash'] if d['look_splash'] is not None else -1
            L.append('\t\tAddDrip("%s", %d, %s, %s, %s, "%s", "%s", %d, %d, %s, %s, %d, "%s", %s);  // %d' % (
                c.name, colour_of(d['trans']), f(d['keep'], 5), f(d['grav']), f(d['alpha'], 3), d['spot'], d['sound'],
                lf, ls, f(sx), f(sy), d['splash_life'], d['water_kids'][0] if d['water_kids'] else '',
                STYLE_CONST[d['style']], i))
        elif c.kind == RK_SMEAR:
            L.append('\t\tAddSmear("%s", %d, %d, %d, %d, %s, "%s", %d, %d);  // %d' % (
                c.name, d['look_t'], d['first'], d['period'], d['count'], f(d['dist']), d['item'], d['amount'], d['chase'], i))
    L += ['\t}', '}', '']
    # actor classes
    for i, c in enumerate(cards):
        d = c.d
        cn = zs_class(c.name)
        if c.kind in (RK_FLOOR, RK_CEIL):
            base = 'RSQGO_ResFloor' if c.kind == RK_FLOOR else 'RSQGO_ResCeil'
            L.append('class %s : %s' % (cn, base))
            L.append('{')
            L.append('\tDefault')
            L.append('\t{')
            L.append('\t\tRSQGO_ResActor.Card %d;' % i)
            if d['trans']:
                L.append('\t\tTranslation %s;' % d['trans'])
            sx, sy = d['scale']
            L.append('\t\tXScale %s;' % f(sx))
            L.append('\t\tYScale %s;' % f(sy))
            L.append('\t\tAlpha %s;' % f(d['alpha'], 3))
            L.append('\t\tRenderStyle "%s";' % d['style'])
            L.append('\t\tHeight %s;' % f(max(0.0, d['height'])))
            L.append('\t}')
            L.append('\tStates')
            L.append('\t{')
            for k, ((spr, fr), w) in enumerate(d['frames']):
                L.append('\tV%d:' % k)
                L.append('\t\t%s %s -1;' % (spr, fr))
                L.append('\t\tStop;')
            L.append('\t}')
            L.append('}')
            L.append('')
        else:
            base = {RK_LAUNCH: 'RSQGO_ResLauncher', RK_DRIPPER: 'RSQGO_ResDripper', RK_DRIP: 'RSQGO_ResDrip',
                    RK_SMEAR: 'RSQGO_ResSmear'}[c.kind]
            # a launcher carries BD's Speed: A_CustomMissile (A_SpawnProjectile, CMF_BADPITCH) sets the velocity from the
            # SPAWNED actor's Speed, i.e. ours after the replacement, and the pitch lives only in that velocity
            spd = ' Speed %s;' % f(d['speed']) if c.kind == RK_LAUNCH else ''
            L.append('class %s : %s { Default { RSQGO_ResActor.Card %d;%s } }' % (cn, base, i, spd))
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')


def write_modeldef(cards, md, path, bd_name):
    L = ['// RSQ Gore residue MODELDEF -- GENERATED by Gore/tools/residue_gen.py from %s. Never hand-edit.' % bd_name,
         '// BD\'s own model blocks for each residue class we spawn instead of BD\'s, renamed to our class: MODELDEF',
         '// matches the exact class (models.cpp FindModelFrameRaw), so without these our spots would draw as sprites.',
         '// The paths are BD\'s (models/bloodspot/...): they resolve from BD\'s pk3, which must be loaded.', '']
    for c in cards:
        if c.kind not in (RK_FLOOR, RK_CEIL):
            continue
        for body in md.get(c.name.lower(), []):
            lines = [ln.rstrip() for ln in body.strip('\n').split('\n') if ln.strip()]
            L.append('Model %s' % zs_class(c.name))
            L.append('{')
            for ln in lines:
                L.append('   ' + ln.strip())
            L.append('}')
            L.append('')
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')


def write_textures(looks, path, bd_name, plan):
    L = ['// RSQ Gore residue TEXTURES -- GENERATED by Gore/tools/residue_gen.py from %s. Never hand-edit.' % bd_name,
         '// The drips: BD\'s falling drip and its landing splash, one texture per frame: BD\'s own UNTRANSLATED lump with',
         '// its sprite offsets (mirrored for a flipped rotation), drawn by a VisualThinker as BD draws the actor\'s sprite,',
         '// at BD\'s scale, through BD\'s class Translation at run time (residue.zs RSQGO_ResVT). Names RSQGO_RL..', '']
    for lk in looks.list:
        for (lump, flipped, tics, (w, h, xo, yo)), name in zip(lk['frames'], lk['tex']):
            if flipped:
                L.append('Texture "%s", %d, %d { Offset %d, %d Patch "%s", 0, 0 { FlipX } }' % (name, w, h, w - xo, yo, lump))
            else:
                L.append('Texture "%s", %d, %d { Offset %d, %d Patch "%s", 0, 0 }' % (name, w, h, xo, yo, lump))
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')


def write_gldefs(looks, path):
    """No mipmaps for our drip textures, as phase 1 does for its own (cards.py write_gldefs: a mipmapped sparse
    droplet averages into a soft pale block)."""
    L = ['// RSQ Gore residue GLDEFS -- GENERATED by Gore/tools/residue_gen.py. Never hand-edit.',
         '// Every drip particle texture of ours drawn without mipmaps (cards.py write_gldefs says why). Our names only.',
         '']
    for lk in looks.list:
        for name in lk['tex']:
            L.append('material texture "%s" { nomipmap }' % name)
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')


def write_animdefs(looks, path):
    L = ['// RSQ Gore residue ANIMDEFS -- GENERATED by Gore/tools/residue_gen.py. Never hand-edit.',
         '// Empty on purpose: each drip splash VisualThinker steps its own frames at BD\'s tics (residue.zs RSQGO_ResVT),',
         '// so no two splashes share one global ANIMDEFS phase. Kept so the pk3 layout does not change.', '']
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')


# What residue.zs does differently from BD, on purpose; kept in step with the header of residue.zs.
NAMED_DIFFERENCES = (
    "spots and pools are placed on their floor at once (BD's fall there first; where they end up is BD's)",
    'smear-zone sight looks are budgeted: zones younger than 700 tics look every tic, at most 128 sight tests a tic; '
    'older ones every 8 tics, at most 32 a tic (BD: every smearer every tic, no cap)',
    'at 8192 live smear zones a new one evicts the oldest zone that never locked (else the locked one ending first)',
    'a smear zone whose ear (the parked actor that spawned it) fades away at Blood That Stays None hears nothing more '
    'and looks by sight only',
    'ceiling launchers follow at most 16 wall bounces (BD: until their 3 or 12 tics run out)',
    "drips: at most 32 falls start a tic and none beyond 3072 units of this machine's camera (cosmetic, local); a "
    'culled fall shows no splash; its landing sound still plays',
    'the ceiling-mover watch runs before the movers: a ceiling spot trails its moving ceiling by one tic (BD: up to 5)',
    'a drip is judged under water once, where it starts (BD re-tests every 4 tics: one falling into deep water '
    'vanishes there; ours lands on the floor beneath)',
)


def write_summary(cards, left, looks, flats, path, bd_name, xmve_name):
    L = ['RSQ Gore residue summary -- GENERATED by Gore/tools/residue_gen.py. Never hand-edit.',
         'Packs: BD = %s, XMVE = %s' % (bd_name, xmve_name),
         'Phase 2 classes: %d cards, %d left to BD.' % (len(cards), len(left)), '']
    by = {}
    for c in cards:
        by.setdefault(c.kind, []).append(c)
    for k in range(6):
        cs = by.get(k, [])
        L.append('== %s (%d)' % (KIND_NAMES[k], len(cs)))
        for c in cs:
            d = c.d
            if k == RK_FLOOR:
                frs = ' '.join('%s%s %s' % (s, fr, f(w, 3)) for (s, fr), w in d['frames'])
                bits = ['%s' % d['sub'], 'frames [%s]' % frs, 'shows t%d' % d['show_t'],
                        'scale %s' % f(abs(d['scale'][0])), 'quad r %s, cover %s-%s' % (f(d['quad'], 1), f(d['cover_lo'], 1), f(d['cover_hi'], 1)),
                        'floor %s@t%d' % (STAND_NAMES[d['stand']], d['check_t'])]
                if d['ramp']:
                    bits.append('ramp t%d-%d %s->%s' % (d['ramp'][0][0], d['ramp'][-1][0], f(d['ramp'][0][1], 2), f(d['ramp'][-1][1], 2)))
                if d['smear_cls']:
                    bits.append('smear %s@t%d' % (d['smear_cls'], d['smear_t']))
                if d['lmask']:
                    bits.append('liquid mask %d -> %s (ACS t%d)' % (d['lmask'], d['lcls'] or 'gone', d['acs_t']))
                if d['face']:
                    bits.append('faces its spawner')
                if not d['queued']:
                    bits.append('BD never queues it (permanent in BD; ours is in the ring)')
                bits.append('under water: gone' if d['water_vanish'] else 'under water: stays (BD has no water check)')
                if c.why:
                    bits.append(c.why)
            elif k == RK_CEIL:
                bits = ['frame %s%s' % d['frames'][0][0], 'scale %s' % f(abs(d['scale'][0])),
                        'under water: %s' % ('gone' if d['water_vanish'] else 'stays (BD has no water check)'),
                        'quad r %s' % f(d['quad'], 1), 'leaves %s' % ', '.join('%s@t%d' % (cl, t) for t, cl, a in d['kids'])]
            elif k == RK_LAUNCH:
                bits = ['life %d' % d['life'], 'speed %s' % f(d['speed']), 'gravity %s' % f(d['grav']),
                        'ceiling -> %s' % d['spot'], 'bounces on walls' if d['bounce'] else 'no wall bounce',
                        'under water: %s' % ('gone' if d['water_vanish'] else 'flies (BD has no water check)')]
            elif k == RK_DRIPPER:
                n = sum(rr['count'] for rr in d['runs'])
                bits = ['life %d' % d['life'], '%d drips' % n] + ['%s x%d @t%d/%dt' % (rr['cls'], rr['count'], rr['t'], rr['interval'])
                                                                  for rr in d['runs']]
            elif k == RK_DRIP:
                bits = ['keeps %s' % f(d['keep'], 3), 'look %s%s' % d['look'], 'scale %s/%s' % (f(d['scale'][0]), f(d['scale'][1])),
                        'gravity %s' % f(d['grav']), 'lands: %s' % (d['spot'] or 'no spot'), 'sound %s' % (d['sound'] or '-'),
                        'splash %d tics' % d['splash_life'], 'water -> %s' % (', '.join(d['water_kids']) or 'nothing')]
            else:
                bits = ['look t%d' % d['look_t'], 'checks %d every %d from t%d (lock + %d)' % (d['count'], d['period'], d['first'], d['chase']),
                        'within %s' % f(d['dist']), 'gives %s x%d' % (d['item'], d['amount']), 'ends t%d' % d['end']]
            if getattr(c, 'unresolved', None):
                bits.append('NAMES NON-CARD CLASSES: %s (spawned by name, BD\'s or phase 1\'s)' % ', '.join(c.unresolved))
            L.append('  %s -> %s: %s' % (c.name, zs_class(c.name), '; '.join(bits)))
        L.append('')
    L.append('== Named differences from BD (residue.zs header)')
    for ln in NAMED_DIFFERENCES:
        L.append('  - ' + ln)
    L.append('')
    L.append('== Left to BD (%d)' % len(left))
    for n, why in left:
        L.append('  %s: %s' % (n, why))
    L.append('')
    L.append('== Liquid floors (BD_CheckIfOverLiquid, SPLASH.acs): %s' % ', '.join('%s=%d' % x for x in flats))
    L.append('== Drip particle looks: %d (%s)' % (len(looks.list), ', '.join(lk['name'] for lk in looks.list)))
    if looks.missing:
        L.append('   MISSING sprite frames: %s' % ', '.join(sorted(looks.missing)))
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    packs = [(argv[1], 'BD'), (argv[2], 'XMVE')]
    world, cards, left, looks, flats, md, idx = build(packs)
    bd_name = os.path.basename(argv[1])
    plan, bakes = make_bakes(looks, packs, DOOM2_WAD)
    write_bakes(bakes, GORE)
    write_zs(cards, looks, flats, idx, OUT_ZS, bd_name)
    write_modeldef(cards, md, OUT_MODELDEF, bd_name)
    write_textures(looks, OUT_TEX, bd_name, plan)
    write_animdefs(looks, OUT_ANIM)
    write_gldefs(looks, OUT_GL)
    write_summary(cards, left, looks, flats, OUT_SUM, bd_name, os.path.basename(argv[2]))
    kinds = {}
    for c in cards:
        kinds[KIND_NAMES[c.kind]] = kinds.get(KIND_NAMES[c.kind], 0) + 1
    print('residue_gen: %d cards (%s), %d left to BD, %d drip looks (%d baked colour frames), %d liquid floors' % (
        len(cards), ', '.join('%s %d' % kv for kv in sorted(kinds.items())), len(left), len(looks.list), len(bakes),
        len(flats)))
    for n, why in left:
        print('  left: %s: %s' % (n, why))
    for c in cards:
        if getattr(c, 'unresolved', None):
            print('  %s names non-card classes: %s' % (c.name, ', '.join(c.unresolved)))
    for p in (OUT_ZS, OUT_MODELDEF, OUT_TEX, OUT_ANIM, OUT_GL, OUT_SUM):
        print('  wrote %s' % os.path.relpath(p, os.path.dirname(GORE)))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
