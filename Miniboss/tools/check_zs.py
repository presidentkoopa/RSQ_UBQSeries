#!/usr/bin/env python3
"""check_zs.py -- RSQ Miniboss's own static check of its ZScript, run where no engine is (the rework of 2026-11-09 was
written without a compiler; an earlier build had 4 compile errors caught only by review). Heuristics, not a compiler:

  ERRORS
    - braces / brackets / parentheses that do not balance (strings and comments skipped)
    - a field and a method of one class (extend class merged) with the same name, ignoring case; a method or a field
      declared twice (ZScript has no overloading)
    - a ZScript keyword used as a variable, parameter or field name
    - a class-level static const array used inside a STATIC function (unknown there on this build: SlowMo down.zs,
      11-07); new ones should be function-local
    - a multi-return assignment [a, b] = F() whose count differs from F's declared returns
    - a call on the handler, the set piece or a known static (h.X, b.X, RSQMB_Handler.X ...) to a method that does not
      exist in that class
    - a TranslationID kept in an int
    - a cvar read by name (CI / CF / CVar.FindCVar / GetCVar / UCv / CLocal / MENUDEF) that CVARINFO does not declare
    - a texture asked for by name that neither graphics/ nor the IWAD list below has
    - a sound played by name that is not one of Doom's (the list below)
    - a class reached by string (GiveInventoryType, FindInventory, Has, Give, Spawn, Find) that this mod does not declare
      and that is not on the known-foreign list (another mod's, found by name at run time)
    - a request to RSQVR_Service / RSQSM_Service / RSQGD_Service / RSQMN_RosterService that the shared contract
      (/tmp/contract.md) or that service's own file does not name
  WARNINGS
    - class-level static const arrays (allowed in non-static code; listed)
python3 -I Miniboss/tools/check_zs.py      exit 1 on an error
"""
import os, re, sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))     # Miniboss/
HUB = os.path.dirname(HERE)
ZS = os.path.join(HERE, 'zscript', 'rsqmb')

KEYWORDS = {'play', 'ui', 'cross', 'dot', 'clearscope', 'virtualscope', 'in', 'out', 'default', 'until', 'class', 'struct', 'enum', 'const', 'static', 'native', 'action', 'state',
            'states', 'property', 'flagdef', 'meta', 'mixin', 'extend', 'readonly', 'internal', 'transient', 'abstract',
            'final', 'override', 'virtual', 'virtualscope', 'clearscope', 'play', 'ui', 'deprecated', 'version', 'vararg',
            'latent', 'sealed', 'goto', 'stop', 'loop', 'wait', 'fail', 'super', 'self', 'null', 'true', 'false', 'sizeof',
            'alignof', 'let', 'return', 'break', 'continue', 'switch', 'case', 'if', 'else', 'for', 'while', 'do', 'foreach',
            'is', 'new', 'cross', 'dot', 'bright', 'fast', 'slow', 'nodelay', 'canraise', 'offset', 'light', 'char',
            'array', 'map', 'function', 'auto', 'include', 'protected', 'private', 'unsafe', 'out'}
TYPES = r'(?:int|uint|int8|uint8|int16|uint16|double|float|bool|String|Name|Sound|Color|Vector2|Vector3|Vector4|Quat|TextureID|TranslationID|SpriteID|StateLabel|Actor|Object|Thinker|Service|Inventory|PlayerPawn|Weapon|let|[A-Z]\w*(?:<[^>]+>)?)'

# Doom's own sound names this mod plays (SNDINFO of Doom / Doom II)
SOUNDS = {'brain/spit', 'misc/chat', 'misc/teleport', 'weapons/bfgx', 'misc/w_pkup', 'imp/shotx', 'brain/sight', 'misc/p_pkup'}
# the IWAD's graphics asked for by name (Doom's small font X; the original Minibosses! sprites are looked up by frame)
IWAD_TEX = {'STCFN088'}
# classes of other mods, reached by name at run time (never linked)
FOREIGN = {'champion_Token', 'champion_PersistentInfo', 'champion_DarkRedToken', 'champion_UndyingToken', 'champion_CloneToken',
           'LDLegendaryMonsterToken', 'LDLegendaryMonsterPickupGuaranteed', 'LDLegendaryMonsterTransformed', 'RSQ_ScoreLifeCrate',
           'RSQA_Menu', 'RSQG_Service', 'RSQGC_GCopyService', 'TeleportFog', 'Megasphere', 'Soulsphere', 'Berserk', 'BlurSphere',
           'Weapon', 'Actor', 'Inventory', 'RSQMB_Probe'}
# requests each foreign service answers (the shared contract 2026-11-09 and the services' own files)
SVC_REQ = {
    'RSQVR_Service': {'beam', 'word', 'word.hold', 'word.clear', 'pop', 'loaded', 'scene.push', 'scene.pop'},
    'RSQSM_Service': {'arrow.add', 'arrow.clear', 'start.bossfight', 'start', 'start.auto', 'countdown'},
    'RSQGD_Service': {'event.tint', 'event.wave', 'event.reroll', 'event.flare', 'enabled', 'event.dark'},
    'RSQMN_RosterService': {'tier', 'tier.next', 'tier.ago', 'tier.from', 'retier', 'set', 'class.set', 'class.tier'},
}
SVC_FIELD = {'vrSvc': 'RSQVR_Service', 'VrService()': 'RSQVR_Service', 'vr': 'RSQVR_Service', 'smSvc': 'RSQSM_Service',
             'gdSvc': 'RSQGD_Service', 'GdService()': 'RSQGD_Service', 'MnService()': 'RSQMN_RosterService',
             'mnSvc': 'RSQMN_RosterService'}


def strip(src):
    """comments out, string contents blanked (kept as "" so lengths and lines stay)"""
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if src.startswith('//', i):
            j = src.find('\n', i); j = n if j < 0 else j
            out.append(' ' * (j - i)); i = j
        elif src.startswith('/*', i):
            j = src.find('*/', i + 2); j = n if j < 0 else j + 2
            out.append(re.sub(r'[^\n]', ' ', src[i:j])); i = j
        elif c in '"\'':
            j = i + 1
            while j < n and src[j] != c:
                j += 2 if src[j] == '\\' else 1
            out.append(c + ' ' * (j - i - 1) + c); i = j + 1
        else:
            out.append(c); i += 1
    return ''.join(out)


def nocomment(src):
    """comments out, strings kept"""
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if src.startswith('//', i):
            j = src.find('\n', i); j = n if j < 0 else j
            out.append(' ' * (j - i)); i = j
        elif src.startswith('/*', i):
            j = src.find('*/', i + 2); j = n if j < 0 else j + 2
            out.append(re.sub(r'[^\n]', ' ', src[i:j])); i = j
        elif c in '"\'':
            j = i + 1
            while j < n and src[j] != c:
                j += 2 if src[j] == '\\' else 1
            out.append(src[i:j + 1]); i = j + 1
        else:
            out.append(c); i += 1
    return ''.join(out)


def line_of(s, pos):
    return s.count('\n', 0, pos) + 1


def blocks(s):
    """top-level class bodies: (name, kind, start, end) with kind 'class' or 'extend'"""
    res = []
    for m in re.finditer(r'^(extend\s+)?class\s+(\w+)[^{;]*\{', s, re.M):
        depth, i = 1, m.end()
        while i < len(s) and depth:
            if s[i] == '{': depth += 1
            elif s[i] == '}': depth -= 1
            i += 1
        res.append((m.group(2), 'extend' if m.group(1) else 'class', m.end(), i - 1))
    return res


def members(body):
    """depth-0 members of a class body: fields, methods (name, returns count, static?, body span), consts, enums"""
    fields, methods, consts, arrays = [], [], [], []
    depth, i, n, start = 0, 0, len(body), 0
    stmt = ''
    while i < n:
        c = body[i]
        if depth == 0 and c == '{' and '=' in body[start:i] and not re.search(r'\)\s*(const)?\s*$', body[start:i].strip()):
            # an initializer (static const int X[] = { ... };): skip to its end, the statement ends at the ';'
            d, j = 1, i + 1
            while j < n and d:
                if body[j] == '{': d += 1
                elif body[j] == '}': d -= 1
                j += 1
            i = j
            continue
        if depth == 0 and c == '{':
            head = body[start:i]
            # find the matching brace
            d, j = 1, i + 1
            while j < n and d:
                if body[j] == '{': d += 1
                elif body[j] == '}': d -= 1
                j += 1
            hm = None
            hs = head.strip()
            if re.search(r'\)\s*(const)?$', hs):
                # the parameter list: back from the last ')' to its '(' (defaults may hold parentheses)
                k = hs.rfind(')'); d2 = 0
                while k >= 0:
                    if hs[k] == ')': d2 += 1
                    elif hs[k] == '(':
                        d2 -= 1
                        if d2 == 0: break
                    k -= 1
                if k > 0:
                    hm = re.search(r'([\w<>,\s\[\]]+?)\s+(\w+)\s*$', hs[:k], re.S)
                    if hm: hm = (hm, hs[k + 1:hs.rfind(')')])
            em = re.search(r'\benum\s+(\w+)', head)
            if em:
                for e in re.findall(r'(\w+)\s*(?:=[^,}]*)?(?:,|$)', body[i + 1:j - 1]):
                    consts.append(e)
            elif hm and not re.search(r'\b(Default|States)\b', head):
                hm, params = hm
                ret = hm.group(1).strip()
                mods = set(ret.split())
                rettypes = re.sub(r'\b(static|virtual|override|clearscope|play|ui|private|protected|native|final|action|deprecated|version|virtualscope|transient|readonly|internal)\b|\([^)]*\)', '', ret).strip()
                nret = 0 if rettypes in ('void', '') else len([x for x in rettypes.split(',') if x.strip()])
                methods.append((hm.group(2), nret, 'static' in mods, start, i, j, params))
            i, start = j, j
            continue
        if depth == 0 and c == ';':
            st = body[start:i].strip()
            start = i + 1
            if not st or st.startswith('#'):
                i += 1; continue
            cm = re.match(r'(?:static\s+)?const\s+(\w+)\s*=', st)
            sa = re.match(r'static\s+const\s+\w+\s+(\w+)\s*\[\s*\]', st)
            if sa:
                arrays.append(sa.group(1))
            elif cm:
                consts.append(cm.group(1))
            elif re.match(r'(?:(?:transient|ui|play|private|protected|readonly|native|meta|internal)\s+)*' + TYPES + r'\s+[\w\s,\[\]]+$', st, re.S):
                decl = re.sub(r'^(?:(?:transient|ui|play|private|protected|readonly|native|meta|internal)\s+)*', '', st)
                tm = re.match(TYPES + r'\s+(.*)$', decl, re.S)
                if tm:
                    for nm in tm.group(1).split(','):
                        nm = nm.strip().split('[')[0].strip()
                        if re.match(r'^\w+$', nm): fields.append(nm)
        i += 1
    return fields, methods, consts, arrays


def main():
    errs, warns = [], []
    files = sorted(os.path.join(ZS, f) for f in os.listdir(ZS) if f.endswith('.zs'))
    raw = {f: open(f, encoding='utf-8').read() for f in files}
    src = {f: strip(raw[f]) for f in files}
    nc = {f: nocomment(raw[f]) for f in files}
    rel = lambda f: os.path.relpath(f, HUB)

    # ---- balance
    for f, s in src.items():
        for o, c in ('{}', '()', '[]'):
            if s.count(o) != s.count(c):
                errs.append(f'{rel(f)}: unbalanced {o}{c}: {s.count(o)} vs {s.count(c)}')

    # ---- classes merged (extend)
    cls = {}     # name -> dict(fields, methods{lower: (name, nret, static, file, line)}, consts, arrays)
    method_bodies = []    # (class, name, static, file, body text)
    for f, s in src.items():
        for name, kind, a, b in blocks(s):
            body = s[a:b]
            fl, ms, cs, ar = members(body)
            C = cls.setdefault(name, {'fields': {}, 'methods': {}, 'consts': set(), 'arrays': set()})
            for x in fl:
                if x.lower() in C['fields']:
                    errs.append(f'{rel(f)}: field {x} of {name} declared twice')
                C['fields'][x.lower()] = (x, f)
            for (mn, nret, st, hs, he, be, params) in ms:
                ln = line_of(s, a + hs)
                if mn.lower() in C['methods'] and mn != name:
                    errs.append(f'{rel(f)}:{ln}: method {mn} of {name} declared twice (no overloading in ZScript; other at {rel(C["methods"][mn.lower()][3])}:{C["methods"][mn.lower()][4]})')
                C['methods'][mn.lower()] = (mn, nret, st, f, ln)
                method_bodies.append((name, mn, st, f, s[a + he:a + be], a + he, params))
            C['consts'] |= set(cs)
            C['arrays'] |= set(ar)
    for name, C in cls.items():
        for k, (mn, *_r) in C['methods'].items():
            if k in C['fields']:
                errs.append(f'class {name}: field {C["fields"][k][0]} and method {mn} share a name (case-insensitive)')
        for a in C['arrays']:
            warns.append(f'class {name}: class-level static const array {a}')

    # ---- keywords as identifiers (declarations: a type, then the name, then = ; , ) )
    decl = re.compile(r'\b(?:int|uint|double|float|bool|String|Name|Color|Vector2|Vector3|TextureID|TranslationID|Actor|Object|let|Service|Inventory|PlayerPawn|RSQMB_\w+)\s+(\w+)\s*(?=[=;,)])')
    for f, s in src.items():
        for m in decl.finditer(s):
            if m.group(1).lower() in KEYWORDS:
                errs.append(f'{rel(f)}:{line_of(s, m.start())}: keyword "{m.group(1)}" used as a name')

    # ---- class-level arrays inside static functions
    for (cn, mn, st, f, body, pos, params) in method_bodies:
        if not st: continue
        for a in cls.get(cn, {}).get('arrays', ()):
            local = re.search(r'static\s+const\s+\w+\s+' + a + r'\s*\[', body)
            if re.search(r'\b' + a + r'\b', body) and not local:
                errs.append(f'{rel(f)}:{line_of(src[f], pos)}: class-level static const array {a} used in static {cn}.{mn}')

    # ---- multi-return arity
    allm = {}
    for cn, C in cls.items():
        for k, v in C['methods'].items(): allm.setdefault(k, []).append(v)
    for f, s in src.items():
        for m in re.finditer(r'\[([\w\s,]+)\]\s*=\s*(?:[\w.]+\.)?(\w+)\s*\(', s):
            n = len([x for x in m.group(1).split(',') if x.strip()])
            cands = allm.get(m.group(2).lower())
            if cands and all(c[1] != n for c in cands):
                errs.append(f'{rel(f)}:{line_of(s, m.start())}: [{m.group(1).strip()}] = {m.group(2)}(): {n} names, it returns {cands[0][1]}')

    # ---- calls on known receivers
    recv = {'h': 'RSQMB_Handler', 'hd': 'RSQMB_Handler', 'hnd': 'RSQMB_Handler', 'RSQMB_Handler': 'RSQMB_Handler',
            'b': 'RSQMB_Boss', 'boss': 'RSQMB_Boss', 'bfBoss': 'RSQMB_Boss', 'RSQMB_Boss': 'RSQMB_Boss',
            'RSQMB_A11y': 'RSQMB_A11y', 'RSQMB_XFx': 'RSQMB_XFx', 'fxp': 'RSQMB_FxPool', 'RSQMB_FxPool': 'RSQMB_FxPool'}
    for f, s in src.items():
        bound = {r for r in ('h', 'hd', 'hnd') if re.search(r'\b' + r + r'\s*=\s*(?:RSQMB_Handler|H\(\)|HD\(\))|RSQMB_Handler\s+' + r + r'\b', nc[f])}
        for m in re.finditer(r'\b(\w+)\.(\w+)\s*\(', s):
            r, mn = m.group(1), m.group(2)
            if r not in recv: continue
            if r in ('h', 'hd', 'hnd') and r not in bound: continue
            C = cls.get(recv[r])
            if not C: continue
            if mn.lower() not in C['methods'] and mn not in ('Size', 'Push', 'Find', 'Clear', 'Delete', 'Destroy', 'GetClassName', 'Insert'):
                if recv[r] == 'RSQMB_Boss' and mn.lower() in ('changestatnum',): continue
                errs.append(f'{rel(f)}:{line_of(s, m.start())}: {r}.{mn}(): no such method in {recv[r]}')
        # constants on a class
        for m in re.finditer(r'\b(RSQMB_Handler|RSQMB_Boss|RSQMB_FxPool|RSQMB_Fx)\.([A-Z_][A-Z0-9_]+)\b(?!\s*\()', s):
            C = cls.get(m.group(1))
            if C and m.group(2) not in C['consts'] and m.group(2) not in C['arrays']:
                errs.append(f'{rel(f)}:{line_of(s, m.start())}: {m.group(1)}.{m.group(2)}: no such constant')

    # ---- TranslationID kept in an int
    for f, s in src.items():
        for m in re.finditer(r'\bint\s+\w+\s*=\s*[\w.]*Translation\b', s):
            errs.append(f'{rel(f)}:{line_of(s, m.start())}: a TranslationID kept in an int')

    # ---- cvars
    cvi = open(os.path.join(HERE, 'CVARINFO.txt'), encoding='utf-8').read()
    declared = set(re.findall(r'^\s*(?:server|user|nosave|noarchive|\s)*\s*(?:bool|int|float|string|color)\s+(\w+)', cvi, re.M))
    known_foreign_cv = {'rsm_depth', 'rsq_ui_inset', 'rsq_ui_hud_scale', 'LD_legendarymonsters', 'LD_legendaryhealth',
                        'LD_legendaryhealthboss', 'rsq_mon_bf_boss', 'rsq_mon_bf_thralls'}   # last two: RSQ Monsters' Bossfight rows
    for f, s in nc.items():
        for m in re.finditer(r"""(?:\bCI|\bCF|FindCVar|GetCVar|\bUCv|\bCLocal|\bCv|\bI|\bF)\s*\(\s*['"](\w+)['"]""", s):
            v = m.group(1)
            if v.startswith('rsqa_') or v.startswith('vr_'): continue   # RSQ Accessibility's (a11y.zs); the engine's VR cvars
            if v not in declared and v not in known_foreign_cv:
                errs.append(f'{rel(f)}:{line_of(s, m.start())}: cvar {v} not in CVARINFO')
    md = open(os.path.join(HERE, 'MENUDEF.txt'), encoding='utf-8').read()
    for m in re.finditer(r'^\s*(?:Option|Slider)\s+"[^"]*",\s*"(\w+)"', md, re.M):
        if m.group(1) not in declared:
            errs.append(f'MENUDEF.txt: row cvar {m.group(1)} not in CVARINFO')
    for v in sorted(declared):
        if not any(v in s for s in nc.values()) and v not in md:
            warns.append(f'CVARINFO: {v} is read nowhere')

    # ---- textures, sounds, classes by name
    gfx = {os.path.splitext(x)[0].upper() for x in os.listdir(os.path.join(HERE, 'graphics'))}
    for f, s in nc.items():
        for m in re.finditer(r'CheckForTexture\s*\(\s*"(\w+)"', s):
            if m.group(1).upper() not in gfx and m.group(1) not in IWAD_TEX:
                errs.append(f'{rel(f)}:{line_of(s, m.start())}: texture {m.group(1)} not in graphics/ nor the IWAD list')
        for m in re.finditer(r'A_StartSound\s*\(\s*"([^"]+)"', s):
            if m.group(1) not in SOUNDS:
                errs.append(f'{rel(f)}:{line_of(s, m.start())}: sound {m.group(1)} not on the list of Doom sounds')
        for m in re.finditer(r'(?:GiveInventoryType|FindInventory|TakeInventory|\bHas\s*\(\s*\w+\s*,|\bGive\s*\(\s*\w+\s*,|Actor\.Spawn|VisualThinker\.Spawn|ThinkerIterator\.Create|EventHandler\.Find)\s*\(?\s*"(\w+)"', s):
            c = m.group(1)
            if c not in cls and c not in FOREIGN and not c.startswith('champion_'):
                errs.append(f'{rel(f)}:{line_of(s, m.start())}: class {c} reached by string: not declared here nor known')

    # ---- service requests
    for f, s in nc.items():
        for m in re.finditer(r'(\w+(?:\(\))?)\s*\.GetInt\s*\(\s*"([\w.]+)"', s):
            who = SVC_FIELD.get(m.group(1))
            if who and m.group(2) not in SVC_REQ[who]:
                errs.append(f'{rel(f)}:{line_of(s, m.start())}: {who} request "{m.group(2)}" not in the contract / its file')

    for w in warns: print('warning:', w)
    for e in errs: print('ERROR:', e)
    print(f'check_zs: {len(files)} files, {len(cls)} classes, {sum(len(c["methods"]) for c in cls.values())} methods: '
          f'{len(errs)} errors, {len(warns)} warnings')
    return 1 if errs else 0


if __name__ == '__main__':
    sys.exit(main())
