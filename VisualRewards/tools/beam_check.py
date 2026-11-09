#!/usr/bin/env python3
"""beam_check.py -- checks the arrival beams, monster words and pops without an engine (tool only; never ships).
Modelled on Grenade/tools/barrel_check.py.

    python3 VisualRewards/tools/beam_check.py

THE CHECKS (over zscript/rsqvr/beams.zs, words.zs, beam_data.zs and service.zs):
  - braces, parentheses and brackets balance (strings and comments skipped);
  - every sprite name the data registers has files, every frame the table names exists and carries a grAb offset, no
    beam file goes unused, and no sprite name is used by another mod of the series;
  - every font texture the metrics can draw (QVW032..096 with a width) and every pop frame exists, with grAb;
  - every sound played is in SNDINFO.txt and its file is in sounds/;
  - every cvar read is declared in CVARINFO.txt (here, or RSQ Accessibility's for rsqa_*), and the new menu rows'
    cvars too; the reset alias carries them;
  - the contract's requests ("beam", "word", "word.hold", "word.clear", "pop") are answered by RSQVR_Service;
  - MAPINFO adds RSQVR_FxHandler and zscript.txt includes the three new files;
  - the ones a compiler would make that a text check can: no class-level static const array (they do not resolve on this
    build); a translation is held as TranslationID, never int; no identifier that is a ZScript keyword; no field and method
    of one class with the same name in any case; no field of an Actor subclass named like an Actor member; every flag in
    a Default block is one the engine has (a fixed list); every RSQVR_BeamData.X used is a constant or table it has; the
    frame offsets the code adds stay inside their set.
"""
import os, re, sys, glob, struct

HERE = os.path.dirname(os.path.abspath(__file__))
VR = os.path.dirname(HERE)
HUB = os.path.dirname(VR)
PK3 = os.path.join(VR, 'pk3')
ZDIR = os.path.join(PK3, 'zscript', 'rsqvr')
FILES = [os.path.join(ZDIR, f) for f in ('beams.zs', 'words.zs', 'beam_data.zs', 'service.zs')]
SPR = os.path.join(PK3, 'sprites', 'rsqvr', 'beam')
GFX = os.path.join(PK3, 'graphics', 'rsqvrw')
KEYWORDS = {'until', 'in', 'out', 'default', 'class', 'struct', 'enum', 'const', 'static', 'native', 'action', 'readonly',
            'internal', 'version', 'property', 'flagdef', 'mixin', 'extend', 'replaces', 'abstract', 'ui', 'play',
            'clearscope', 'virtualscope', 'transient', 'meta', 'final', 'virtual', 'override', 'private', 'protected',
            'sizeof', 'alignof', 'is', 'let', 'auto', 'map', 'array', 'states', 'loop', 'stop', 'wait', 'fail', 'goto',
            'do', 'while', 'for', 'foreach', 'if', 'else', 'switch', 'case', 'return', 'break', 'continue', 'super', 'self',
            'true', 'false', 'null', 'cross', 'dot', 'color', 'sound', 'state', 'name', 'string', 'vector2', 'vector3',
            'bright', 'fast', 'slow', 'nodelay', 'offset', 'light', 'latent', 'deprecated', 'var', 'set'}
ACTOR_MEMBERS = {'players', 'level', 'default', 'pos', 'vel', 'angle', 'pitch', 'roll', 'scale', 'alpha', 'target', 'master',
                 'tracer', 'health', 'height', 'radius', 'speed', 'gravity', 'translation', 'sprite', 'frame', 'tics',
                 'floorz', 'ceilingz', 'waterlevel', 'cursector', 'special', 'args', 'score', 'mass', 'damage', 'flags',
                 'tid', 'friction', 'bouncefactor', 'renderstyle', 'stencilcolor', 'fillcolor', 'consoleplayer', 'prev',
                 'spawnpoint', 'meleerange', 'floorclip', 'accuracy', 'stamina', 'threshold', 'reactiontime', 'movedir',
                 'lastheard', 'goal', 'activationtype', 'species', 'obituary', 'painchance', 'look', 'die', 'tick',
                 'activate', 'deactivate', 'touch', 'revive', 'destroy', 'show', 'hide', 'spawn', 'warp', 'morph'}
FLAGS_OK = {'NOBLOCKMAP', 'NOTELEPORT', 'DONTSPLASH', 'THRUACTORS', 'NOTRIGGER', 'CLIENTSIDEONLY', 'NOTONAUTOMAP',
            'FORCEXYBILLBOARD', 'ROLLSPRITE', 'NOINTERACTION', 'NOGRAVITY', 'BRIGHT', 'WALLSPRITE', 'FLATSPRITE'}
SERIES_MODS = ['Accessibility', 'DistanceGrab', 'Grapple', 'Grenade', 'GunBonsaiOffhandVR', 'GunCards', 'LaserSight',
               'Melee', 'Miniboss', 'Monsters', 'QuestSaber', 'Score', 'ShieldSaw', 'SlowMo', 'TacticalRig', 'Wheel', 'Whip',
               'FlashFlare', 'GlowInTheDark']
problems = []


def bad(m): problems.append(m)


def strip_code(src):
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


def no_comments(src):
    """comments blanked, strings kept"""
    out = []; i = 0; n = len(src)
    while i < n:
        if src.startswith('//', i):
            j = src.find('\n', i); j = n if j < 0 else j; out.append(' ' * (j - i)); i = j
        elif src[i] in '"\'':
            q = src[i]; j = i + 1
            while j < n and src[j] != q: j += 2 if src[j] == '\\' else 1
            out.append(src[i:j + 1]); i = j + 1
        else:
            out.append(src[i]); i += 1
    return ''.join(out)


def has_grab(path):
    d = open(path, 'rb').read()
    return b'grAb' in d[:200]


def classes(code):
    """(name, parent, body) for each class, by brace matching"""
    out = []
    for m in re.finditer(r'\bclass\s+(\w+)(?:\s*:\s*(\w+))?[^{;]*\{', code):
        i = m.end(); depth = 1
        while depth and i < len(code):
            if code[i] == '{': depth += 1
            elif code[i] == '}': depth -= 1
            i += 1
        out.append((m.group(1), m.group(2), code[m.end():i - 1]))
    return out


def top_level(body):
    """the class body with every nested {...} blanked: its members' declarations only"""
    out = []; depth = 0
    for c in body:
        if c == '{': depth += 1; out.append(' ' if depth > 1 else c); continue
        if c == '}': depth -= 1; out.append(' ' if depth >= 1 else c); continue
        out.append(c if depth == 0 else (' ' if c != '\n' else '\n'))
    return ''.join(out)


TYPES = r'(?:int|uint|double|float|bool|String|Name|Vector2|Vector3|Color|TextureID|TranslationID|Sound|SpriteID|Actor|' \
        r'Array<[^>]+>|RSQVR_\w+|CVar|PlayerPawn|Sector|Object)'


def main():
    src = {f: open(f).read() for f in FILES}
    code = {f: strip_code(s) for f, s in src.items()}
    # ---- balance
    for f, c in code.items():
        for o, cl in ('{}', '()', '[]'):
            if c.count(o) != c.count(cl): bad('%s: %s %d vs %s %d' % (os.path.basename(f), o, c.count(o), cl, c.count(cl)))
    # ---- the data
    data = src[os.path.join(ZDIR, 'beam_data.zs')]
    consts = dict((k, int(v)) for k, v in re.findall(r'const\s+(\w+)\s*=\s*(-?\d+);', data))
    funcs = set(re.findall(r'static\s+\w+\s+(\w+)\s*\(', data))
    m = re.search(r'static String SPR\(int i\)\s*\{\s*static const String T\[\] = \{ ([^}]*) \};', data)
    sprnames = re.findall(r'"(\w{4})"', m.group(1)) if m else []
    if len(sprnames) != consts.get('NSPR'): bad('beam_data: NSPR %s but %d names' % (consts.get('NSPR'), len(sprnames)))
    reg = re.search(r'class RSQVR_BeamSprites.*?Spawn:\s*(.*?)Stop;', data, re.S)
    regd = set(re.findall(r'(\w{4}) A 0;', reg.group(1))) if reg else set()
    for s in sprnames:
        if s not in regd: bad('sprite %s is not registered in RSQVR_BeamSprites' % s)
    def table(fn):
        mm = re.search(r'static int %s\(int i\)\s*\{\s*static const int T\[\] = \{ ([^}]*) \};' % fn, data)
        return [int(x) for x in mm.group(1).split(',')] if mm else []
    fs, ff, fw, fh = table('FR_SPR'), table('FR_FRM'), table('FR_W'), table('FR_H')
    if not (len(fs) == len(ff) == len(fw) == len(fh) == consts.get('NFRAMES')):
        bad('beam_data: frame tables differ in length (%d %d %d %d, NFRAMES %s)' % (len(fs), len(ff), len(fw), len(fh), consts.get('NFRAMES')))
    used = set()
    for i in range(min(len(fs), len(ff))):
        name = '%s%s0.png' % (sprnames[fs[i]], chr(65 + ff[i]))
        p = os.path.join(SPR, name); used.add(name)
        if not os.path.exists(p): bad('frame %d: %s missing' % (i, name))
        elif not has_grab(p): bad('frame %d: %s has no grAb offset' % (i, name))
    for f in os.listdir(SPR):
        if f not in used: bad('unused beam sprite file %s' % f)
    # sprite names of the rest of the series
    for mod in SERIES_MODS:
        for p in glob.glob(os.path.join(HUB, mod, '**', 'sprites', '**', '*.*'), recursive=True):
            b = os.path.basename(p).upper()
            if b[:4] in sprnames: bad('sprite name %s also used by %s (%s)' % (b[:4], mod, p))
    # font and pop
    fa = re.search(r'static int FONT_W\(int c\)\s*\{\s*static const int T\[\] = \{ ([^}]*) \};', data)
    fwid = [int(x) for x in fa.group(1).split(',')] if fa else []
    if len(fwid) != 65: bad('FONT_W has %d entries, not 65' % len(fwid))
    for i, w in enumerate(fwid):
        c = 32 + i
        p = os.path.join(GFX, 'QVW%03d.png' % c)
        if c != 32 and w > 0 and not os.path.exists(p): bad('font glyph %s missing' % os.path.basename(p))
        elif os.path.exists(p) and not has_grab(p): bad('%s has no grAb' % p)
    for i in range(consts.get('POP_N', 0)):
        p = os.path.join(GFX, 'QVPOP%02d.png' % i)
        if not os.path.exists(p): bad('pop frame %s missing' % os.path.basename(p))
        elif not has_grab(p): bad('%s has no grAb' % p)
    if not os.path.exists(os.path.join(GFX, 'QVW065.png')): bad('QVW065 (the pool\'s first texture) missing')
    # every RSQVR_BeamData.X used exists
    allc = ''.join(code.values())
    for x in set(re.findall(r'RSQVR_BeamData\.(\w+)', allc)):
        if x not in consts and x not in funcs: bad('RSQVR_BeamData.%s is not in beam_data.zs' % x)
    # frame offsets stay inside their set: F_SET + n (literal)
    sets = {}
    for mm in re.finditer(r'const (F_\w+) = (\d+);\s*// (\d+) frames', data): sets[mm.group(1)] = (int(mm.group(2)), int(mm.group(3)))
    for mm in re.finditer(r'RSQVR_BeamData\.(F_\w+)\s*\+\s*(\d+)\s*\+\s*(\w+)', allc):
        pass
    for mm in re.finditer(r'RSQVR_BeamData\.(F_\w+)\s*\+\s*(\d+)(?!\s*[\*\w])', allc):
        s, n = mm.group(1), int(mm.group(2))
        if s in sets and n >= sets[s][1]: bad('%s + %d is past its %d frames' % (s, n, sets[s][1]))
    # the code's own offsets: columns (kind*5 + phase < 15), licks (side 5 + ln-3 < 10), flames (side 10 + hot 5 + ln-5 < 20)
    if sets.get('F_COL2', (0, 0))[1] != 15 or sets.get('F_LICK', (0, 0))[1] != 10 or sets.get('F_FLAME', (0, 0))[1] != 20 \
            or sets.get('F_ZFX', (0, 0))[1] != 6 or sets.get('F_SKULL', (0, 0))[1] != 19 or sets.get('F_BEAM', (0, 0))[1] != 5 \
            or sets.get('F_SPARK', (0, 0))[1] != 2:
        bad('a frame set changed size: beams.zs indexes columns 3x5, licks 2x5, flames 2x2x5, ZFX 6, skull 19, beam 5, spark 2')
    # ---- sounds
    snd = open(os.path.join(PK3, 'SNDINFO.txt')).read() if os.path.exists(os.path.join(PK3, 'SNDINFO.txt')) else ''
    defs = dict(re.findall(r'^(\S+)\s+(\S+)\s*$', '\n'.join(l for l in snd.splitlines() if not l.strip().startswith('//')), re.M))
    for mm in re.finditer(r'^\$random\s+(\S+)\s*\{([^}]*)\}', snd, re.M):
        for member in mm.group(2).split():
            if member not in defs: bad('$random %s: member %s not defined' % (mm.group(1), member))
        defs[mm.group(1)] = None
    played = set(re.findall(r'"(rsqvr/[\w/]+)"', src[os.path.join(ZDIR, 'beams.zs')]))
    for s in played:
        if s not in defs: bad('sound %s is not in SNDINFO.txt' % s)
    for s, f in defs.items():
        if f and not os.path.exists(os.path.join(PK3, f)): bad('SNDINFO %s -> %s: file missing' % (s, f))
    # ---- cvars
    cvi = open(os.path.join(PK3, 'CVARINFO.txt')).read()
    declared = set(re.findall(r'^\s*(?:server|user|nosave|noarchive|\s)*\s*(?:bool|int|float|string|color)\s+(\w+)', cvi, re.M))
    a11y = open(os.path.join(HUB, 'Accessibility', 'CVARINFO.txt')).read() if os.path.exists(os.path.join(HUB, 'Accessibility', 'CVARINFO.txt')) else ''
    for f in FILES:
        for cv in re.findall(r"(?:FindCVar|GetCvar|GetCVar)\('(\w+)'", src[f]):
            if cv not in declared and not (cv.startswith('rsqa_') and cv in a11y): bad('%s reads cvar %s: not declared' % (os.path.basename(f), cv))
    menu = open(os.path.join(PK3, 'MENUDEF.txt')).read()
    keyc = open(os.path.join(PK3, 'KEYCONF.txt')).read()
    for cv in ('rsqvr_beams', 'rsqvr_words', 'rsqvr_pops'):
        if cv not in declared: bad('cvar %s not declared' % cv)
        if '"%s"' % cv not in menu: bad('cvar %s has no menu row' % cv)
        if 'resetcvar %s' % cv not in keyc: bad('cvar %s missing from the rsqthp_reset alias' % cv)
    # ---- the contract
    svc = code[os.path.join(ZDIR, 'service.zs')]; svcs = src[os.path.join(ZDIR, 'service.zs')]
    for r in ('beam', 'word', 'word.hold', 'word.clear', 'pop'):
        if not re.search(r'request\s*==\s*"%s"' % re.escape(r), svcs): bad('RSQVR_Service does not answer "%s"' % r)
    if 'RSQVR_FxHandler' not in open(os.path.join(PK3, 'MAPINFO.txt')).read(): bad('MAPINFO does not add RSQVR_FxHandler')
    zt = open(os.path.join(PK3, 'zscript.txt')).read()
    for f in ('beam_data.zs', 'beams.zs', 'words.zs'):
        if 'zscript/rsqvr/%s' % f not in zt: bad('zscript.txt does not include %s' % f)
    # ---- what a compiler would say
    for f in FILES:
        c = code[f]; bn = os.path.basename(f)
        for name, parent, body in classes(c):
            tl = top_level(body)
            for mm in re.finditer(r'^\s*static\s+const\s+\w+\s+(\w+)\s*\[\]', tl, re.M):
                bad('%s %s: class-level static const array %s' % (bn, name, mm.group(1)))
            fields = set()
            for mm in re.finditer(r'^\s*(?:transient\s+|private\s+|protected\s+|readonly\s+|meta\s+)*(' + TYPES + r')\s+([\w\s,]+);', tl, re.M):
                for v in mm.group(2).split(','):
                    v = v.strip()
                    if v: fields.add(v)
            methods = set(re.findall(r'^\s*(?:static\s+|override\s+|virtual\s+|private\s+|protected\s+|clearscope\s+|play\s+|ui\s+|action\s+|final\s+)*'
                                     r'(?:void|' + TYPES + r'(?:\s*,\s*' + TYPES + r')*)\s+(\w+)\s*\(', tl, re.M))
            fl = {x.lower() for x in fields}
            for mth in methods:
                if mth.lower() in fl: bad('%s %s: field and method both named %s' % (bn, name, mth))
            for v in fields | methods:
                if v.lower() in KEYWORDS: bad('%s %s: %s is a ZScript keyword' % (bn, name, v))
            is_actor = parent in ('Actor', 'RSQVR_BeamPiece')
            if is_actor:
                for v in fields:
                    if v.lower() in ACTOR_MEMBERS: bad('%s %s: field %s is an Actor member' % (bn, name, v))
                for v in methods:
                    if v.lower() in ACTOR_MEMBERS and v not in ('Tick',): bad('%s %s: method %s is named like an Actor member' % (bn, name, v))
            for mm in re.finditer(r'Default\s*\{(.*?)\}', body, re.S):
                for fl_ in re.findall(r'[+-](\w+)', mm.group(1)):
                    if fl_.upper() not in FLAGS_OK: bad('%s %s: flag %s not in the known list' % (bn, name, fl_))
        # locals and parameters named like keywords
        for mm in re.finditer(r'\b(?:int|double|bool|String|Vector2|Vector3|Color|TextureID|TranslationID)\s+(\w+)\s*[=;,)]', c):
            if mm.group(1).lower() in KEYWORDS: bad('%s: a variable named %s (keyword)' % (bn, mm.group(1)))
        # translations held as int
        for mm in re.finditer(r'\bint\s+\w+\s*=\s*[^;]*(?:AddTranslation|Trans\()', c):
            bad('%s: a translation held as int: %s' % (bn, mm.group(0)))
        for mm in re.finditer(r'Array<int>\s+\w*[tT]rans\w*', c):
            bad('%s: translations in an int array: %s' % (bn, mm.group(0)))
        # function-local `const` (not static const arrays): not ZScript
        for mm in re.finditer(r'^\t\t+const\s+\w+\s*=', c, re.M):
            bad('%s: a local const (use a variable): %s' % (bn, mm.group(0).strip()))
    # Trans returns TranslationID
    if not re.search(r'TranslationID\s+Trans\(int rgb, bool font\)', code[os.path.join(ZDIR, 'words.zs')]):
        bad('RSQVR_FxHandler.Trans must return TranslationID')
    if problems:
        print('beam_check: %d problem(s)' % len(problems))
        for p in problems: print('  -', p)
        sys.exit(1)
    print('beam_check: ok (%d frames, %d sprite names, %d font glyphs, %d pop frames, %d sounds)' %
          (consts.get('NFRAMES', 0), len(sprnames), sum(1 for w in fwid if w), consts.get('POP_N', 0), len(defs)))


if __name__ == '__main__':
    main()
