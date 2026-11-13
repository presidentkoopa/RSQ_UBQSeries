#!/usr/bin/env python3
"""How many sprite frames would hand-made recolours of Brutal Doom 22's and XMVE's monsters cost?

QuestZDoom 17.3 indexes sprite frames in 16 bits: the whole load order must stay at or under 65,535 frames. A recoloured
frame under a NEW sprite name costs one frame per letter (A..max) of that name. This walks every tierable BD22 / XMVE
monster (design/tiering/data/bd_xmve_ladders.csv, entry tier not 'exempt') through every actor its DECORATE / ZScript
reaches (spawned, thrown, given, its parent's states), collects every sprite those actors draw, and keeps the ones whose
lumps live in a monster-art folder (body, deaths, fatalities, frozen and burnt bodies, gore). Each such sprite name is
priced at its frame count in the engine's own sprite table (the gdb dump of the full load order, rig run rc_count0).

Usage: measure_frames.py LADDER_CSV SPRITES_BIN OUT_JSON SRC_ROOT [SRC_ROOT ...]
SRC_ROOTs are unpacked pk3 folders (untrusted data: only read as text and file names).
"""
import re, os, sys, json, glob, struct, csv, collections

ladder_csv, sprites_bin, out_json = sys.argv[1:4]
roots = sys.argv[4:]

# ---------------------------------------------------------------- engine sprite table (name -> numframes)
d = open(sprites_bin, 'rb').read()
ENGINE = {}
for i in range(len(d) // 12):
    r = d[i*12:i*12+12]
    ENGINE[r[:4].decode('latin1').upper()] = r[8]
ENGINE_TOTAL = sum(ENGINE.values())

# ---------------------------------------------------------------- lumps: sprite name -> folders it lives in
LUMPDIR = collections.defaultdict(set)
for r in roots:
    for sd in ('sprites', 'Sprites', 'SPRITES'):
        base = os.path.join(r, sd)
        if not os.path.isdir(base): continue
        for f in glob.glob(base + '/**/*', recursive=True):
            if not os.path.isfile(f): continue
            rel = os.path.relpath(f, base)
            folder = os.path.dirname(rel) or '.'
            LUMPDIR[os.path.basename(f)[:4].upper()].add(os.path.basename(r) + ':' + folder)

def art_kind(spr):
    """Which kind of art a sprite name is, from the folders its lumps are in (BD22's folder wins over XMVE's copy:
    XMVE files its generic gore, blood and flames under Sprites/Monsters/GORE)."""
    fs = LUMPDIR.get(spr, set())
    if not fs: return 'iwad-or-other'
    bd = [f for f in fs if f.startswith('bd22:')]
    low = ' '.join(bd or fs).lower()
    if 'blood' in low or 'flames' in low or 'flares' in low or 'smoke' in low or 'explosions' in low or 'sfx' in low or 'particles' in low: return 'not-body'
    if 'carbonized' in low or 'burningman' in low: return 'burnt'
    if 'frozen' in low or 'freeze' in low: return 'frozen'
    if 'monsterfatality' in low or 'stealthkills' in low: return 'fatality'
    if re.search(r':monsters/gore\b', low) or 'gore_generic' in low or 'goregeneric' in low or ':gore' in low: return 'gore'
    if ':monsters' in low: return 'monster'
    return 'not-body'

BODY_KINDS = ('monster', 'fatality', 'frozen', 'gore', 'burnt')

# ---------------------------------------------------------------- DECORATE / ZScript actors
def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', lambda m: '\n' * m.group(0).count('\n'), t, flags=re.S)
    return re.sub(r'//[^\n]*', '', t)

HDR = re.compile(r'^\s*(?:actor|class)\s+"?([\w.\-]+)"?\s*(?::\s*"?([\w.\-]+)"?)?', re.I)
STATE = re.compile(r'^\s*(?:[\w.]+\s*:\s*)*"?([A-Za-z0-9_\[\]\\#\-]{4})"?\s+"?([A-Za-z\[\]\\#^]+)"?\s+(-?\d+|random)', re.I)
LABEL = re.compile(r'^\s*([\w.]+)\s*:(?!:)')
QUOTED = re.compile(r'"([\w.\-]+)"')
CALLARG = re.compile(r'\b(?:A_\w+|DropItem|Spawn\w*)\s*\(?\s*"?([A-Za-z_][\w.\-]*)"?', re.I)
DROP = re.compile(r'^\s*dropitem\s+"?([\w.\-]+)"?', re.I | re.M)

ACT = {}
files = []
for r in roots:
    for f in glob.glob(r + '/**/*', recursive=True):
        if not os.path.isfile(f) or os.path.getsize(f) > 6_000_000: continue
        rel = os.path.relpath(f, r).lower()
        if rel.startswith(('sprites', 'sounds', 'textures', 'graphics', 'music', 'models', 'voxels', 'maps', 'flats', 'acs')): continue
        if re.search(r'\.(png|lmp|wav|ogg|mp3|flac|wad|o|md3|dmd|kvx|jpg|pcx|tga|bmp)$', rel): continue
        files.append(f)

for f in files:
    try: t = strip_comments(open(f, encoding='latin-1').read())
    except Exception: continue
    if not re.search(r'^\s*(actor|class)\s', t, re.I | re.M): continue
    lines = t.split('\n'); i = 0
    while i < len(lines):
        m = HDR.match(lines[i])
        if not m or re.match(r'^\s*actor\s+\w+\s*\(', lines[i], re.I): i += 1; continue
        j = i; depth = 0; started = False; body = []
        while j < len(lines):
            for ch in lines[j]:
                if ch == '{': depth += 1; started = True
                elif ch == '}': depth -= 1
            body.append(lines[j])
            if started and depth <= 0: break
            j += 1
            if not started and j - i > 3: break
        name = m.group(1); key = name.lower()
        b = '\n'.join(body)
        labels = collections.defaultdict(set); cur = None; in_states = False
        for L in body:
            if re.search(r'\bstates\b', L, re.I): in_states = True; continue
            if not in_states: continue
            lm = LABEL.match(L)
            if lm: cur = lm.group(1).lower()
            sm = STATE.match(L)
            if sm and cur:
                spr = sm.group(1).upper()
                if spr in ('####', '----', 'TNT1'): continue
                for c in sm.group(2).upper():
                    if c not in '#^': labels[cur].add((spr, c))
        refs = set(x.lower() for x in QUOTED.findall(b)) | set(x.lower() for x in CALLARG.findall(b)) | set(x.lower() for x in DROP.findall(b))
        top = re.split(r'\bstates\b', b, flags=re.I)[0]
        missile = bool(re.search(r'^\s*(\+missile|projectile)\b', top, re.I | re.M))
        prev = ACT.get(key)
        # later definitions win, as the engine's load order does (roots are given in load order)
        ACT[key] = dict(name=name, parent=(m.group(2) or '').lower(), labels=labels, refs=refs, missile=missile,
                        file=os.path.relpath(f, os.path.dirname(roots[0])) + ':%d' % (i + 1))
        i = j + 1

def eff_labels(key, depth=0):
    a = ACT.get(key)
    if not a: return {}
    out = dict(eff_labels(a['parent'], depth + 1)) if a['parent'] and depth < 20 else {}
    out.update(a['labels'])
    return out

def is_kind(key, base, depth=0):
    a = ACT.get(key)
    if key == base: return True
    if not a or depth > 20: return False
    return is_kind(a['parent'], base, depth + 1)

def blocked(key):
    """Traversal stops at weapons, players and pickups (their art is not a monster's body). Missiles are followed:
    Brutal Doom throws its limbs and gibs as missiles (A_CustomMissile("XDeathImpArm")); a fireball's own art is
    left out later by its folder (Flames, Explosions, ...)."""
    if key not in ACT: return True
    return any(is_kind(key, b) for b in ('weapon', 'playerpawn', 'ammo', 'health', 'armor', 'basicarmorpickup', 'powerupgiver'))

rows = [x for x in csv.DictReader(open(ladder_csv)) if x['entry tier'] != 'exempt']
ROOTS = [(x['source'], x['class'], x['family']) for x in rows]
rootkeys = set(c.lower() for _, c, _ in ROOTS)

fam_report = {}
sprite_owner = collections.defaultdict(set)     # sprite -> roots that reach it
sprite_letters = collections.defaultdict(set)
for src, cls, fam in ROOTS:
    key = cls.lower(); seen = set(); stack = [key]; actors = []
    while stack:
        k = stack.pop()
        if k in seen: continue
        seen.add(k)
        if k not in ACT: continue
        actors.append(k)
        for r in ACT[k]['refs'] | ({ACT[k]['parent']} if ACT[k]['parent'] else set()):
            if r in seen or r not in ACT: continue
            if r in rootkeys and r != key: continue           # another monster on the ladder: its own family
            if blocked(r) and r != key: continue
            stack.append(r)
    sprs = collections.defaultdict(set)
    for k in actors:
        for lab, ss in eff_labels(k).items():
            for spr, c in ss: sprs[spr].add(c)
    body = {s: sorted(c) for s, c in sprs.items() if art_kind(s) in BODY_KINDS}
    for s, c in body.items():
        sprite_owner[s].add(cls); sprite_letters[s] |= set(c)
    fam_report[cls] = dict(source=src, family=fam, actors=len(actors),
                           body_sprites=len(body), body_frames=sum(ENGINE.get(s, 0) for s in body),
                           body_frames_used=sum(len(c) for c in body.values()))

# "Only the most visible frames": the living monster's own states (not its deaths, corpses, gore or fatalities)
ALIVE = re.compile(r'^(spawn|stand|idle|see|missile|melee|pain|lookingforplayer|seecontinue|advancing|fireballattack|leapattack)', re.I)
alive_letters = collections.defaultdict(set)
for src, cls, fam in ROOTS:
    for lab, ss in eff_labels(cls.lower()).items():
        if not ALIVE.match(lab): continue
        for spr, c in ss:
            if art_kind(spr) == 'monster': alive_letters[spr].add(c)
ALIVE_USED = sum(len(v) for v in alive_letters.values())

kinds = collections.Counter(); kinds_used = collections.Counter()
for s in sprite_owner:
    kinds[art_kind(s)] += ENGINE.get(s, 0); kinds_used[art_kind(s)] += len(sprite_letters[s])
U = sum(ENGINE.get(s, 0) for s in sprite_owner)
U_used = sum(len(v) for v in sprite_letters.values())
imp = [s for s in sprite_owner if 'Imp' in sprite_owner[s]]
out = dict(engine_total=ENGINE_TOTAL, cap=65535, headroom=65535 - ENGINE_TOTAL,
           roots=len(ROOTS), actors_parsed=len(ACT),
           body_sprite_names=len(sprite_owner), body_frames_union=U, body_frames_used_letters=U_used,
           by_kind=dict(kinds), by_kind_used_letters=dict(kinds_used),
           times12=U * 12, over_by=ENGINE_TOTAL + U * 12 - 65535,
           alive_sprite_names=len(alive_letters), alive_frames_used=ALIVE_USED, alive_times12=ALIVE_USED * 12,
           alive_over_by=ENGINE_TOTAL + ALIVE_USED * 12 - 65535,
           times12_used=U_used * 12, over_by_used=ENGINE_TOTAL + U_used * 12 - 65535,
           imp=dict(sprites={s: dict(frames=ENGINE.get(s, 0), used=''.join(sorted(sprite_letters[s])), kind=art_kind(s),
                                     shared_with=len(sprite_owner[s]) - 1) for s in sorted(imp)},
                    frames=sum(ENGINE.get(s, 0) for s in imp)),
           families=fam_report,
           sprites={s: dict(frames=ENGINE.get(s, 0), used=''.join(sorted(sprite_letters[s])), kind=art_kind(s),
                            roots=sorted(sprite_owner[s])) for s in sorted(sprite_owner)})
json.dump(out, open(out_json, 'w'), indent=1)
for k in ('engine_total', 'headroom', 'roots', 'actors_parsed', 'body_sprite_names', 'body_frames_union',
          'body_frames_used_letters', 'by_kind', 'by_kind_used_letters', 'times12', 'over_by', 'times12_used', 'over_by_used', 'alive_sprite_names', 'alive_frames_used', 'alive_times12', 'alive_over_by'):
    print(k, out[k])
print('imp family frames', out['imp']['frames'], 'sprites', len(imp))
