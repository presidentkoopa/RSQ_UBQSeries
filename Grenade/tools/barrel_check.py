#!/usr/bin/env python3
"""barrel_check.py -- checks the barrels without an engine (tool only; never ships).

    python3 Grenade/tools/barrel_check.py             the checks
    python3 Grenade/tools/barrel_check.py preview     + tools/barrel_preview/*.png: each sequence re-drawn FROM THE
                                                      EXPORTED DATA (sprites + tracks), side view, beside nothing else:
                                                      put it next to the approved contact sheets to see the export holds

THE CHECKS: braces and parentheses balance in barrel.zs and barrel_data.zs (strings and comments skipped); every
sprite a state names exists (or is the engine's / the IWAD's: TNT1 BAR1 BEXP); every sprite frame the data can show
exists (layer tracks, ember frames A-D, each debris option's palette steps) and carries a grAb offset; no file in
sprites/rsqgn/barrel/ goes unused; no sprite name is used by another mod of the series; every sound played is
defined in SNDINFO.txt and its lump is in sounds/; every cvar read is declared in CVARINFO.txt, and every MENUDEF row's
cvar too; the translation named is in TRNSLATE.txt; the data's parallel arrays have equal lengths.

THE EXPLOSIONS (explosions.zs, the new sequences; added 11-09 after the barrel pass's four compile errors a reviewer
caught): the same checks over explosions.zs and kinds.zs, and the ones a compiler would make that a text check can --
every tint name the code can build (RSQGN_K1-8, T01-13, H00-11) and every literal translation is in TRNSLATE.txt; every
decal sprayed is in DECALDEF.txt and its picture in graphics/; every RSQGN_BarrelData.X used is a table or constant the
data has; T_W is 0/1 and L_FLAT 0-3; no class-level static const array (they do not resolve on this build); no
identifier that is a ZScript keyword; no field and method of one class with the same name in any case (names are case-
insensitive); no member named like an Actor member or a global the code also uses (players, Default, ...); every flag in
a Default block of these files is one the engine has (a fixed list of the ones this pack uses).
"""
import os, re, sys, glob, struct
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
GREN = os.path.dirname(HERE)
HUB = os.path.dirname(GREN)
ZS = os.path.join(GREN, 'zscript', 'rsqgn', 'barrel.zs')
DATA = os.path.join(GREN, 'zscript', 'rsqgn', 'barrel_data.zs')
EXPL = os.path.join(GREN, 'zscript', 'rsqgn', 'explosions.zs')
KINDS = os.path.join(GREN, 'zscript', 'rsqgn', 'kinds.zs')
KEYWORDS = {'until', 'in', 'out', 'default', 'class', 'struct', 'enum', 'const', 'static', 'native', 'action', 'readonly',
            'internal', 'version', 'property', 'flagdef', 'mixin', 'extend', 'replaces', 'abstract', 'ui', 'play',
            'clearscope', 'virtualscope', 'transient', 'meta', 'final', 'virtual', 'override', 'private', 'protected',
            'sizeof', 'alignof', 'is', 'let', 'auto', 'map', 'array', 'states', 'loop', 'stop', 'wait', 'fail', 'goto',
            'do', 'while', 'for', 'foreach', 'if', 'else', 'switch', 'case', 'return', 'break', 'continue', 'super', 'self',
            'true', 'false', 'null', 'cross', 'dot', 'color', 'sound', 'state', 'name', 'string', 'vector2', 'vector3',
            'bright', 'fast', 'slow', 'nodelay', 'offset', 'light', 'latent', 'deprecated', 'var'}
# members of Actor / globals a member must not be named after (a clash the compiler refuses or that silently shadows)
RESERVED = {'players', 'level', 'default', 'pos', 'vel', 'angle', 'pitch', 'roll', 'scale', 'alpha', 'target', 'master',
            'tracer', 'health', 'height', 'radius', 'speed', 'gravity', 'translation', 'sprite', 'frame', 'tics', 'age_',
            'floorz', 'ceilingz', 'waterlevel', 'cursector', 'special', 'args', 'score', 'mass', 'damage', 'flags',
            'tid', 'friction', 'bouncefactor', 'renderstyle', 'stencilcolor', 'fillcolor', 'kind_', 'consoleplayer'}
FLAGS_OK = {'NOBLOCKMAP', 'NOTELEPORT', 'DONTSPLASH', 'THRUACTORS', 'NOTRIGGER', 'CLIENTSIDEONLY', 'NOTONAUTOMAP',
            'FORCEXYBILLBOARD', 'ROLLSPRITE', 'NOINTERACTION', 'NOGRAVITY', 'BRIGHT', 'DROPOFF', 'MISSILE',
            'BLOODLESSIMPACT', 'GHOST', 'WALLSPRITE', 'FLATSPRITE'}
SPR = os.path.join(GREN, 'sprites', 'rsqgn', 'barrel')
SPR_NEW = os.path.join(GREN, 'sprites', 'rsqgn', 'blast')
ENGINE_SPRITES = {'TNT1', 'BAR1', 'BEXP'}
problems = []


def bad(msg): problems.append(msg)


def strip_code(src):
    """the code with strings, names and comments blanked (so braces inside them do not count)"""
    out = []; i = 0; n = len(src)
    while i < n:
        c = src[i]
        if src.startswith('//', i):
            j = src.find('\n', i); j = n if j < 0 else j; out.append(' ' * (j - i)); i = j
        elif src.startswith('/*', i):
            j = src.find('*/', i + 2); j = n if j < 0 else j + 2; out.append(' ' * (j - i)); i = j
        elif c in '"\'':
            j = i + 1
            while j < n and src[j] != c:
                j += 2 if src[j] == '\\' else 1
            out.append(c + ' ' * (j - i - 1) + c); i = j + 1
        else:
            out.append(c); i += 1
    return ''.join(out)


def balance(path):
    code = strip_code(open(path).read())
    for o, c in ('{}', '()', '[]'):
        depth = 0
        for ln, line in enumerate(code.split('\n'), 1):
            for ch in line:
                depth += (ch == o) - (ch == c)
                if depth < 0: bad(f'{os.path.basename(path)}:{ln}: unmatched {c}'); depth = 0
        if depth: bad(f'{os.path.basename(path)}: {depth} unclosed {o}')


def arrays(path):
    src = open(path).read()
    res = {}
    for m in re.finditer(r'static const (\w+) (\w+)\[\] =\s*\{(.*?)\};', src, re.S):
        typ, name, body = m.groups()
        if name.endswith('_T'): name = name[:-2]   # the exporter's function-local table: TABLE(i) holds TABLE_T[]
        vals = [v.strip() for v in body.replace('\n', ' ').split(',') if v.strip()]
        res[name] = [v.strip('"') for v in vals] if typ == 'String' else [int(v) for v in vals]
    return res


def state_sprites(path):
    """sprite + frames on state lines (a 4-char name, frames, a tic count)"""
    code = strip_code(open(path).read())
    out = []
    for blk in re.finditer(r'\bStates\s*\{(.*?)\n\t\}', code, re.S):
        for m in re.finditer(r'^\s*(?:\w+:\s*)?([A-Z0-9_]{4})\s+([A-Z\[\]\\#]+)\s+-?\d+', blk.group(1), re.M):
            out.append((m.group(1), m.group(2)))
        for m in re.finditer(r'([A-Z0-9]{4}) ([A-Z]) 0;', blk.group(1)):
            out.append((m.group(1), m.group(2)))
    return out


def grab(path):
    b = open(path, 'rb').read()
    i = b.find(b'grAb')
    return struct.unpack('>ii', b[i + 4:i + 12]) if i > 0 else None


def main():
    for p in (ZS, DATA, EXPL, KINDS): balance(p)
    A = arrays(DATA)
    groups = defaultdict(list)
    for k, v in A.items():
        if '_' in k: groups[k.split('_')[0]].append((k, len(v)))
    for g, ks in groups.items():
        if g in ('Q', 'L', 'T', 'E', 'D', 'O') and len({n for _, n in ks}) > 1: bad(f'array lengths differ in {g}_: {ks}')
    files = {os.path.basename(f)[:-4].upper(): f for f in glob.glob(os.path.join(SPR, '*.png')) + glob.glob(os.path.join(SPR_NEW, '*.png'))}
    used = set()
    spr = A['SPR']

    def need(name, fr):
        key = f'{name}{fr}0'
        used.add(key)
        if key not in files: bad(f'missing sprite {key}.png')
        elif not grab(files[key]): bad(f'{key}.png has no grAb offset')
    # every state's sprites
    for path in (ZS, DATA):
        for name, frames in state_sprites(path):
            if name in ENGINE_SPRITES: continue
            for fr in frames: need(name, fr)
    # the layer tracks
    for s, f in zip(A['T_SPR'], A['T_FRM']):
        if s >= 0: need(spr[s], chr(65 + f))
    for s in A['E_SPR']:
        for f in 'ABCD': need(spr[s], f)
    for s, n in zip(A['O_SPR'], A['O_LEN']):
        for f in range(n): need(spr[s], chr(65 + f))
    for k in files:
        if k not in used: bad(f'unused sprite file {k}.png')
    # sprite names clash with nothing else in the series
    ours = {s.upper() for s in spr}
    for f in glob.glob(os.path.join(HUB, '*', '**', 'sprites', '**', '*'), recursive=True):
        if os.path.isdir(f) or os.path.dirname(f).startswith(SPR) or os.path.dirname(f).startswith(SPR_NEW): continue
        nm = os.path.basename(f)[:4].upper()
        if nm in ours: bad(f'sprite name {nm} also in {os.path.relpath(f, HUB)}')
    # sounds
    snd = open(os.path.join(GREN, 'SNDINFO.txt')).read()
    defined = set(re.findall(r'^\s*\$random\s+(\S+)', snd, re.M)) | set(re.findall(r'^\s*([a-z][\w/]+)\s+[A-Z]\w+', snd, re.M))
    for m in re.finditer(r'^\s*([a-z][\w/]+)\s+([A-Z]\w+)', snd, re.M):
        lump = m.group(2)
        if not glob.glob(os.path.join(GREN, 'sounds', '**', lump + '*'), recursive=True): bad(f'SNDINFO lump {lump} has no file')
    src = open(ZS).read() + open(EXPL).read()
    for s in re.findall(r'A_StartSound\("([^"]+)"', src):
        if s not in defined: bad(f'sound {s} not in SNDINFO')
    # cvars
    cvi = open(os.path.join(GREN, 'CVARINFO.txt')).read()
    declared = set(re.findall(r'^\s*(?:server|user)\s+\w+\s+(\w+)', cvi, re.M))
    for c in re.findall(r'FindCVar\("([^"]+)"\)', src):
        if c not in declared: bad(f'cvar {c} read but not declared')
    menu = open(os.path.join(GREN, 'MENUDEF.txt')).read()
    for c in re.findall(r'^\s*(?:Option|Slider|RSQGNGbOption|RSQGNGbSlider)\s+"[^"]*",\s*"([^"]+)"', menu, re.M):
        if c not in declared: bad(f'MENUDEF cvar {c} not declared')
    for ov in re.findall(r'^\s*Option\s+"[^"]*",\s*"[^"]+",\s*"([^"]+)"', menu, re.M):
        if ov != 'OnOff' and f'OptionValue "{ov}"' not in menu: bad(f'MENUDEF OptionValue {ov} not defined')
    trn = open(os.path.join(GREN, 'TRNSLATE.txt')).read()
    for t in re.findall(r"A_SetTranslation\('([^']+)'\)", src):
        if not re.search(r'^\s*' + re.escape(t) + r'\s*=', trn, re.M): bad(f'translation {t} not in TRNSLATE.txt')
    # classes the handlers and spawns name
    classes = set(re.findall(r'^class (\w+)', src + open(DATA).read(), re.M))
    for c in re.findall(r'Spawn\("(\w+)"', src) + re.findall(r'Find\("(\w+)"\)', src):
        if c not in classes: bad(f'class {c} spawned / found but not declared')
    mi = open(os.path.join(GREN, 'MAPINFO.txt')).read()
    for c in ('RSQGN_BarrelSwap', 'RSQGN_BarrelBook'):
        if c not in mi: bad(f'{c} not in MAPINFO AddEventHandlers')
    explosions_checks(A, trn, menu, declared)
    print(f'{len(files)} sprite files, {len(spr)} sprite names, {len(used)} frames reachable')
    print('\n'.join(problems) if problems else 'OK: no problems found')
    return A, files


def explosions_checks(A, trn, menu, declared):
    ex = open(EXPL).read()
    code_all = {p: strip_code(open(p).read()) for p in (ZS, EXPL, KINDS, DATA)}
    # the tints the code can build, and literal ones
    names = {f'RSQGN_K{i}' for i in range(1, 9)} | {f'RSQGN_T{i:02d}' for i in range(1, 14)} | {f'RSQGN_H{i:02d}' for i in range(12)}
    for t in names:
        if not re.search(r'^\s*' + t + r'\s*=', trn, re.M): bad(f'tint {t} not in TRNSLATE.txt')
    for c in ('RSQGN_K%d', 'RSQGN_T%02d', 'RSQGN_H%02d'):
        if f'"{c}"' not in ex: bad(f'explosions.zs no longer builds {c} (the tint list above is out of step)')
    # decals
    dd = open(os.path.join(GREN, 'DECALDEF.txt')).read()
    for d in re.findall(r'A_SprayDecal\("([^"]+)"', ex):
        m = re.search(r'^decal\s+' + d + r'\s*\{(.*?)\}', dd, re.M | re.S)
        if not m: bad(f'decal {d} not in DECALDEF.txt'); continue
        pic = re.search(r'pic\s+(\w+)', m.group(1)).group(1)
        if not glob.glob(os.path.join(GREN, 'graphics', '**', pic + '.png'), recursive=True): bad(f'decal picture {pic} not in graphics/')
    for an in re.findall(r'animator\s+(\w+)', dd):
        if not re.search(r'^(fader|stretcher|slider|colorchanger|combiner)\s+' + an + r'\b', dd, re.M): bad(f'DECALDEF animator {an} undefined')
    # the data's names used by the code
    data = open(DATA).read()
    consts = set(re.findall(r'^\tconst (\w+) =', data, re.M)) | set(A.keys())
    for p, code in code_all.items():
        for nm in re.findall(r'RSQGN_BarrelData\.(\w+)', code):
            if nm not in consts: bad(f'{os.path.basename(p)}: RSQGN_BarrelData.{nm} does not exist')
    if any(v not in (0, 1) for v in A['T_W']): bad('T_W holds something other than 0/1')
    if any(v not in (0, 1, 2, 3) for v in A['L_FLAT']): bad('L_FLAT outside 0-3')
    if any(v not in (0, 1) for v in A['L_NOTINT']): bad('L_NOTINT holds something other than 0/1')
    for p in (ZS, EXPL, KINDS):
        code = code_all[p]; fn = os.path.basename(p)
        # class-level static const arrays (one tab in from the class)
        for m in re.finditer(r'^\tstatic const \w+ \w+\[\]', code, re.M): bad(f'{fn}: class-level static const array: {m.group(0).strip()}')
        # keyword identifiers in declarations
        for m in re.finditer(r'\b(?:int|double|bool|float|String|Name|Vector2|Vector3|Actor|let)\s+(\w+)\s*[=;,)\[]', code):
            if m.group(1).lower() in KEYWORDS: bad(f'{fn}: identifier "{m.group(1)}" is a ZScript keyword')
        for m in re.finditer(r'^\s*(?:int|double|bool|float|String|Name)\s+([^;(]+);', code, re.M):   # name lists: int a, b, c;
            for f in m.group(1).split(','):
                f = re.sub(r'\[.*', '', f.split('=')[0]).strip()
                if f.lower() in KEYWORDS: bad(f'{fn}: identifier "{f}" is a ZScript keyword')
        # per class: fields vs methods, case-insensitive; reserved member names
        for cm in re.finditer(r'^class (\w+)[^\n]*\n\{(.*?)^\}', code, re.M | re.S):
            cls, body = cm.group(1), cm.group(2)
            fields, methods = set(), set()
            for line in body.split('\n'):
                if not line.startswith('\t') or line.startswith('\t\t'): continue
                m = re.match(r'\t(?:transient\s+|private\s+)*(?:int|double|bool|float|String|Name|Vector2|Vector3|TranslationID|Array<\w+>|RSQGN_\w+|Actor)\s+([^(;]+);', line)
                if m:
                    for f in m.group(1).split(','):
                        f = re.sub(r'\[.*', '', f.split('=')[0]).strip()
                        if f: fields.add(f.lower())
                m = re.match(r'\t(?:static\s+|override\s+|virtual\s+|clearscope\s+|action\s+)*\w[\w<>]*\s+(\w+)\s*\(', line)
                if m: methods.add(m.group(1).lower())
            for c in fields & methods: bad(f'{fn} {cls}: "{c}" is both a field and a method (names are case-insensitive)')
            for c in fields & RESERVED: bad(f'{fn} {cls}: field "{c}" clashes with an Actor member or a global')
        # flags in Default blocks
        for blk in re.findall(r'Default\s*\{(.*?)\}', code, re.S):
            for f in re.findall(r'[+-]([A-Za-z]+)\b', blk):
                if f.upper() not in FLAGS_OK and not f.upper().startswith('INVENTORY'): bad(f'{fn}: flag {f} not in the known list (check it is real)')
    # menu rows of the Explosions section
    for c in ('rsqgn_blast_style', 'rsqgn_fx_colour', 'rsqgn_fx_lights', 'rsqgn_ctx', 'rsqgn_ctx_wall', 'rsqgn_ctx_ceiling',
              'rsqgn_ctx_sky', 'rsqgn_ctx_water', 'rsqgn_ctx_liquid', 'rsqgn_ctx_chain', 'rsqgn_ctx_crowd',
              'rsqgn_chain_escalate', 'rsqgn_chain_kick'):
        if c not in declared: bad(f'cvar {c} not declared')
        if f'"{c}"' not in menu: bad(f'cvar {c} has no menu row')
    for c in re.findall(r'RSQGN_Fx\.(?:B|N|Ctx)\("([^"]+)"', ex):
        if c.startswith('rsqgn_') and c not in declared: bad(f'explosions.zs reads cvar {c}, not declared')


def preview(A, files):
    """each sequence's billboard and flat layers re-drawn from the exported tracks (roll 0 where it is random)"""
    import numpy as np
    from PIL import Image
    out = os.path.join(HERE, 'barrel_preview')
    os.makedirs(out, exist_ok=True)
    spr = A['SPR']
    cache = {}

    def img(name):
        if name not in cache:
            im = Image.open(files[name]); cache[name] = (im.convert('RGBA'), grab(files[name]))
        return cache[name]
    for q in range(len(A['Q_L0'])):
        big = q >= A.get('BARRELS', [6])[0] if isinstance(A.get('BARRELS'), list) else q >= 6
        U = 0.9 if big else 1.6; W = H = 420 if big else 240; FL = H - 40; BX = W // 2
        tics = list(range(0, 44, 2))
        sheet = Image.new('RGB', (W * 11, H * 2), (10, 10, 14))
        for n, tic in enumerate(tics):
            c = np.zeros((H, W, 3), float); c[:] = (8, 8, 12); c[FL:] = (16, 15, 18)
            for i in range(A['Q_L0'][q], A['Q_L0'][q] + A['Q_LN'][q]):
                age = tic - A['L_START'][i]
                if age < 0 or age >= A['L_TLEN'][i]: continue
                t = A['L_TOFS'][i] + age
                if A['T_SPR'][t] < 0: continue
                im, (gx, gy) = img(f"{spr[A['T_SPR'][t]]}{chr(65 + A['T_FRM'][t])}0".upper())
                sx, sy = A['T_SX'][t] / 1000 * U, A['T_SY'][t] / 1000 * U
                if A['L_FLAT'][i]: sy *= 0.25       # a flat on the floor, seen from just above
                w2, h2 = max(1, round(im.width * sx)), max(1, round(im.height * sy))
                r = im.resize((w2, h2), Image.NEAREST)
                if A['L_RMODE'][i] == 0 and A['L_ROLL'][i] % 360 and not A['L_FLAT'][i]:
                    r = r.rotate(A['L_ROLL'][i], expand=True, resample=Image.NEAREST)
                cx = BX + A['T_X'][t] / 100 * U; cz = FL - A['T_Z'][t] / 100 * U
                ox = int(round(cx - gx * sx - (r.width - w2) / 2)); oy = int(round(cz - gy * sy - (r.height - h2) / 2))
                a = np.asarray(r).astype(float) / 255.
                x0, y0 = max(0, ox), max(0, oy); x1, y1 = min(W, ox + r.width), min(H, oy + r.height)
                if x1 <= x0 or y1 <= y0: continue
                sub = a[y0 - oy:y1 - oy, x0 - ox:x1 - ox]; al = sub[..., 3:4] * A['T_A'][t] / 1000
                if A['L_ADD'][i]: c[y0:y1, x0:x1] += sub[..., :3] * 255 * al
                else: c[y0:y1, x0:x1] = c[y0:y1, x0:x1] * (1 - al) + sub[..., :3] * 255 * al
            f = Image.fromarray(np.clip(c, 0, 255).astype(np.uint8))
            sheet.paste(f, ((n % 11) * W, (n // 11) * H))
        sheet.save(os.path.join(out, f'seq{q}.png'))
    print('preview sheets in', out)


if __name__ == '__main__':
    A, files = main()
    if 'preview' in sys.argv: preview(A, files)
    sys.exit(1 if problems else 0)
