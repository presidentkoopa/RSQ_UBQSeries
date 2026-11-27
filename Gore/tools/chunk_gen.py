#!/usr/bin/env python3
"""chunk_gen.py -- RSQ Gore phase 3: Brutal Doom's and XMVE's meat, guts, limbs, heads, halves and casings, transpiled.

    python -I Gore/tools/chunk_gen.py <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>

Design: design/GORE_SYSTEM_DESIGN.md section 2.3 ("Meat and guts", "Limbs, heads, halves", "Casings"), section 5 (the
behaviour these classes must keep), section 7 phase 3. Reads both pk3s straight from their zips (read-only), through
gen_gore.build() (the takeover table) and decorate.py; never edits either module.

WHY A TRANSPILER, NOT PARTICLES. A chunk must fly with the engine's own physics (bounce, wall hits, ceiling sticks,
sliding down walls), play BD's exact frames, sounds, A_Jump odds and damage-type deaths, and a landed limb must stay a
shootable, kickable actor. All of that is BD's DECORATE state machine. So each taken-over class becomes ONE generated
ZScript class, RSQGO_G_<BD class>, whose States are BD's own states (only what is reachable), run natively by the
engine, with these changes and nothing else:

  * spawns of phase 1 liquid classes (the trail a chunk lays every 2 tics: Brutal_FlyingBloodTrail, ...) become a
    direct call into phase 1's emitter (RSQGO_Manager.Process): particles, no actor. Every other spawn keeps BD's class
    name and is spawned by name, so the takeover (phases 1-4) still applies to it;
  * A_QueueCorpse is dropped: a chunk that comes to rest in a -1 frame PARKS (statnum 26, never ticked) and enters RSQ
    Gore's ring, sized by the owner's budget (rsqgo_meat_*), oldest recycled (chunks.zs RSQGO_GibRing);
  * rests that tick forever become parks: a frame of 1000+ tics with no action becomes -1 (BD's 9009-tic
    "CRSB C 9009"); one WITH an action keeps its tics and holds once the action has run (LimbBase's 1900-tic blood
    spot loop: the spot appears at tic 1900 as in BD, BD's repeats every 1900 tics after that are dropped,
    RSQGO_Hold); a loop whose states show one frame with no action becomes -1 (TinyGib's "XDT5 Z 1 Loop"); a 200-999
    tic state inside a loop plays once and then holds (EmptyBrass's rest, RSQGO_LongRest);
  * ONE ACTOR FLIES, THEN BECOMES THE LANDED LIMB. A flier whose landing is "spawn Gib_X here, then stop"
    (XDeathArm1 -> Gib_Arm) is generated as a SUBCLASS of Gib_X: it carries Gib_X's damage factors, pain chances and
    Death.* / Pain states, and at the landing it takes Gib_X's flags and fields and jumps into Gib_X's Spawn
    (RSQGO_Become). Its own labels are renamed F_* so they never shadow Gib_X's; its Death is a dispatcher
    (RSQGO_DeathEntry): its own F_Death while flying, Gib_X's Death once landed;
  * SHARED BASES (Gen.share): what BD keeps in a base class (LimbBase, TinyGib, XDeath2 ...) goes into one generated
    RSQGO_GB_<BD base> that the classes under it inherit, instead of a copy in each (compiled once at startup). Only
    states that read the same in every class under the base go there; chunk_lint proves each class still runs the
    same states as its flattened form;
  * BD's ACS checks become native: BD_CheckIfOverLiquid (the floor against SPLASH.acs's list), BDCheckJanitor /
    BDCheckJanitor2 (LowGraphicsMode: zdoombrutaljanitor, deathmatch, bd_infinitecasings == 0), BDCHeckJanitor3;
  * deprecated DECORATE calls become their ZScript forms (A_ChangeFlag -> b<Flag> / A_ChangeLinkFlags, A_PlaySound ->
    A_StartSound, A_CustomMissile -> A_SpawnProjectile with CMF_BADPITCH, momz -> vel.z, scalex -> scale.x), and every
    BD class name in an argument is passed as a name, never a class constant (ZScript compiles before DECORATE).

A class whose reachable states do something this cannot reproduce is LEFT to BD (it stays BD's actor; the children it
spawns are still taken over), with the reason in generated/chunk_summary.txt.

Writes (never hand-edit): zscript/rsqgo/chunk_cards.zs, MODELDEF.chunks (BD's model blocks for our classes, if any),
generated/chunk_summary.txt. Deterministic: classes in table order.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import decorate  # noqa: E402

# Keep each actor's body text (the properties): decorate.Actor parses only a few of them. A wrapper in this process;
# decorate.py itself is not changed.
if not getattr(decorate.Actor, '_rsqgo_body', False):
    _orig_init = decorate.Actor.__init__

    def _init(self, name, parent, replaces, source, body):
        self.body = body
        _orig_init(self, name, parent, replaces, source, body)
    decorate.Actor.__init__ = _init
    decorate.Actor._rsqgo_body = True

import cards  # noqa: E402
import gen_gore  # noqa: E402

GORE = gen_gore.GORE
ENGINE = os.environ.get('RSQGO_ENGINE', r'E:\DOOMWork\QZD17-engine')
FLAGDEFS = os.path.join(ENGINE, 'src', 'scripting', 'thingdef_data.cpp')
PHASE3 = ('meat+guts', 'limb', 'casing')
PREFIX = 'RSQGO_G_'
OUT = {
    'zscript': os.path.join('zscript', 'rsqgo', 'chunk_cards.zs'),
    'modeldef': 'MODELDEF.chunks',
    'summary': os.path.join('generated', 'chunk_summary.txt'),
}
LONG_FOREVER = 1000         # a frame this long is a rest that ticks for minutes: -1 (parks; Q3: never timed out)
LONG_LOOP = 200             # a state this long inside a loop: play once, then hold (RSQGO_LongRest)
FLIER_PREFIX = 'F_'
BASE_PREFIX = 'RSQGO_GB_'           # a shared base: one BD base class's states, compiled once (Gen.share)
# A reference to a state in the canonical form (Gen.emit): named only when written (Gen.render), by the class holding it
REF_RE = re.compile(r'\x01([^|\x01]+)\|(\d+)\x01')


def ref(nd):
    return '\x01%s|%d\x01' % nd


def ref_node(m):
    return (m.group(1), int(m.group(2)))


def refs_in(txt):
    return [(m.group(1), int(m.group(2))) for m in REF_RE.finditer(txt)]
ENTRY_ALWAYS = ('spawn', 'death', 'crash', 'xdeath', 'crush', 'death.sky', 'death.extreme')
ENTRY_SHOOTABLE = ('death.', 'pain', 'pain.', 'xdeath', 'burn', 'ice', 'disintegrate', 'raise', 'wound')
ACTOR_LABELS = {'null', 'genericfreezedeath', 'genericcrush', 'dieFromSpawn'.lower()}
ZS_FLOW_WORDS = {'stop', 'loop', 'wait', 'fail', 'goto'}
# Flags Die() and A_NoBlocking change: a self-become (a gib landing again after a flight) resets them to the gib's.
PROTECTED = {'NOBLOCKMAP', 'NOSECTOR', 'ISPUFF'}
# The engine's combo keywords (thingdef_properties.cpp "projectile" / "monster"), by the engine's flag names
PROJECTILE_FLAGS = ('NOBLOCKMAP', 'NOGRAVITY', 'DROPOFF', 'MISSILE', 'ACTIVATEIMPACT', 'ACTIVATEPCROSS', 'NOTELEPORT')
MONSTER_FLAGS = ('SHOOTABLE', 'COUNTKILL', 'SOLID', 'CANPUSHWALLS', 'CANUSEWALLS', 'ACTIVATEMCROSS', 'PASSMOBJ',
                 'ISMONSTER')
DIE_FLAGS = ('SHOOTABLE', 'FLOAT', 'SKULLFLY', 'NOGRAVITY', 'DROPOFF', 'CORPSE', 'KILLED', 'JUSTHIT', 'SOLID')

BOUNCE_BITS = {'BOUNCEONWALLS': 1, 'BOUNCEONFLOORS': 2, 'BOUNCEONCEILINGS': 4, 'ALLOWBOUNCEONACTORS': 8,
               'BOUNCEONACTORS': 16, 'BOUNCEAUTOOFF': 32, 'BOUNCELIKEHERETIC': 64, 'NOWALLBOUNCESND': 256,
               'NOBOUNCESOUND': 512, 'EXPLODEONWATER': 1024, 'CANBOUNCEWATER': 2048, 'MBFBOUNCER': 4096,
               'BOUNCEAUTOOFFFLOORONLY': 8192, 'USEBOUNCESTATE': 16384, 'DONTBOUNCEONSHOOTABLES': 32768,
               'BOUNCEONUNRIPPABLES': 65536, 'DONTBOUNCEONSKY': 131072, 'KEEPBOUNCEANGLE': 1 << 19,
               'BOUNCEMODIFIESPITCH': 1 << 20}
USESEE = 128
TYPEMASK = 1 | 2 | 4 | 8 | 32 | 64 | 4096
BOUNCE_TYPES = [('None', 0), ('Doom', 1 | 2 | 4 | 8 | 32), ('Heretic', 2 | 4 | 64), ('Hexen', 1 | 2 | 4 | 8),
                ('DoomCompat', 1 | 2 | 4 | 8 | 32 | USESEE), ('HereticCompat', 2 | 4 | 64 | USESEE),
                ('HexenCompat', 1 | 2 | 4 | 8 | USESEE), ('Grenade', 4096 | 1 | 2 | 4 | 8 | 32), ('Classic', 4096 | 2 | 4)]
DEPRECATED_BOUNCE = {'DOOMBOUNCE': 'DoomCompat', 'HERETICBOUNCE': 'HereticCompat', 'HEXENBOUNCE': 'HexenCompat'}
DEPRECATED_GRAVITY = {'LOWGRAVITY': 0.125, 'QUARTERGRAVITY': 0.25}

ID_MAP = {'momx': 'vel.x', 'momy': 'vel.y', 'momz': 'vel.z', 'velx': 'vel.x', 'vely': 'vel.y', 'velz': 'vel.z',
          'scalex': 'scale.x', 'scaley': 'scale.y', 'x': 'pos.x', 'y': 'pos.y', 'z': 'pos.z'}
ID_OK = {'random', 'frandom', 'random2', 'waterlevel', 'floorz', 'ceilingz', 'health', 'angle', 'pitch', 'alpha', 'mass',
         'radius', 'height', 'speed', 'true', 'false', 'abs', 'sin', 'cos', 'min', 'max', 'clamp', 'gravity'}
CONST_RE = re.compile(r'^(SXF|CMF|CHAN|CHANF|ATTN|AAPTR|FTF|RGF|XF|DMG|FLAG|SPF|CVF|FPF|JLOSF|CLOFF|PTROP|RSF|WARPF)_\w+$', re.I)
# Calls that pass through unchanged (no class constant, no label): ZScript has them with DECORATE's arguments.
PASS = {'a_fadeout': 'A_FadeOut', 'a_fadein': 'A_FadeIn', 'a_setscale': 'A_SetScale', 'a_facetarget': 'A_FaceTarget',
        'a_noblocking': 'A_NoBlocking', 'a_stop': 'A_Stop', 'a_recoil': 'A_Recoil', 'a_setangle': 'A_SetAngle',
        'a_pain': 'A_Pain', 'a_scream': 'A_Scream', 'a_xscream': 'A_XScream', 'a_settranslucent': 'A_SetTranslucent',
        'thrustthingz': 'ThrustThingZ', 'thrustthing': 'ThrustThing', 'radius_quake': 'Radius_Quake',
        'thing_changetid': 'Thing_ChangeTID', 'a_settics': 'A_SetTics', 'a_setpitch': 'A_SetPitch',
        'a_scalevelocity': 'A_ScaleVelocity', 'a_changevelocity': 'A_ChangeVelocity'}
JUMPS = {'a_jump', 'a_jumpif', 'a_checkfloor', 'a_checkceiling', 'a_jumpifinventory', 'a_jumpifhealthlower',
         'a_checksight'}
SPAWNS = {'a_custommissile', 'a_spawnprojectile', 'a_spawnitem', 'a_spawnitemex'}


class Unsupported(Exception):
    pass


# ------------------------------------------------------------------ the engine's flag list (read-only)
def engine_flags(path=FLAGDEFS):
    """(bool flags: ZScript has b<Name> for them, deprecated names, dummy names), upper case."""
    t = open(path, encoding='latin-1').read()
    ok, dep, dummy = set(), set(), set()
    for m in re.finditer(r'DEFINE_FLAG\(\s*\w+\s*,\s*(\w+)\s*,', t):
        ok.add(m.group(1).upper())
    for m in re.finditer(r'DEFINE_FLAG2\(\s*\w+\s*,\s*(\w+)\s*,', t):
        ok.add(m.group(1).upper())
    for m in re.finditer(r'DEFINE_PROTECTED_FLAG\(\s*\w+\s*,\s*(\w+)\s*,', t):
        ok.add(m.group(1).upper())          # Default may set them; scripts change them only through A_ChangeLinkFlags
    for m in re.finditer(r'DEFINE_FLAG2_DEPRECATED\(\s*\w+\s*,\s*(\w+)\s*,', t):
        dep.add(m.group(1).upper())
    for m in re.finditer(r'DEFINE_DEPRECATED_FLAG\(\s*(\w+)\s*,', t):
        dep.add(m.group(1).upper())
    for m in re.finditer(r'DEFINE_DUMMY_FLAG\(\s*(\w+)\s*,', t):
        dummy.add(m.group(1).upper())
    ok -= dep
    ok.discard('NOSAVEGAME')
    return ok, dep, dummy


# ------------------------------------------------------------------ properties
TOK_RE = re.compile(r'"(?:[^"\\]|\\.)*"|[+-]\s*[A-Za-z_][\w.]*|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?|[A-Za-z_][\w.]*|[(),;{}]|\S')
ZERO_ARG = {'monster', 'projectile', 'clearflags', 'skip_super', 'nointeraction'}


def props_text(body):
    depth, i, n = 0, 0, len(body)
    while i < n:
        c = body[i]
        if c == '"':
            j = body.find('"', i + 1)
            if j < 0:
                break
            i = j
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
        elif depth == 0 and body[i:i + 6].lower() == 'states' and (i == 0 or not (body[i - 1].isalnum() or body[i - 1] == '_')):
            mm = re.match(r'states\s*(\([^)]*\))?\s*\{', body[i:], re.I)
            if mm:
                j = decorate.match_brace(body, i + mm.end() - 1)
                return body[:i] + '\n' + body[j + 1:]
        i += 1
    return body


def parse_props(body):
    """[('flag', NAME, bool) | ('kw', name) | ('prop', name, [args])] in source order."""
    toks = TOK_RE.findall(props_text(body))
    out, i, n = [], 0, len(toks)

    def arg(j):
        if j >= n:
            return None, j
        t = toks[j]
        if t == '(':
            depth, k = 0, j
            while k < n:
                if toks[k] == '(':
                    depth += 1
                elif toks[k] == ')':
                    depth -= 1
                    if depth == 0:
                        break
                k += 1
            return ' '.join(toks[j:k + 1]), k + 1
        return t, j + 1

    while i < n:
        t = toks[i]
        if t in (';', ',', '{', '}', ')', '('):
            i += 1
            continue
        if t[0] in '+-' and len(t) > 1 and (t[1].isalpha() or t[1] == '_' or t[1].isspace()):
            out.append(('flag', re.sub(r'^[+-]\s*', '', t).upper().split('.')[-1], t[0] == '+'))
            i += 1
            continue
        if re.match(r'^[A-Za-z_]', t):
            nm = t.lower()
            if nm in ZERO_ARG:
                out.append(('kw', nm))
                i += 1
                continue
            args = []
            a, i = arg(i + 1)
            if a is not None:
                args.append(a)
            while i < n and toks[i] == ',':
                a, i = arg(i + 1)
                if a is not None:
                    args.append(a)
            out.append(('prop', nm, args))
            continue
        i += 1
    return out


class Eff:
    """A class's effective properties, flags and bounce bits through its whole inheritance chain."""

    def __init__(self):
        self.flags = {}          # NAME -> bool (engine bool flags only)
        self.bounce = 0
        self.props = {}          # name -> [args] (last write wins)
        self.sx = self.sy = None
        self.gravity = None
        self.dmgf = {}           # type (lower) -> (spelling, value)
        self.painc = {}
        self.notes = []


def effective(world, key, fl_ok, fl_dep, fl_dummy):
    e = Eff()
    for k in reversed(world.chain(key)):
        a = world.cls[k]
        for ent in parse_props(getattr(a, 'body', '')):
            if ent[0] == 'kw':
                if ent[1] == 'projectile':
                    for f in PROJECTILE_FLAGS:
                        e.flags[f] = True
                elif ent[1] == 'monster':
                    for f in MONSTER_FLAGS:
                        e.flags[f] = True
                elif ent[1] == 'clearflags':
                    e.flags.clear()
                    e.bounce = 0
                elif ent[1] == 'nointeraction':
                    pass
                continue
            if ent[0] == 'flag':
                f, v = ent[1], ent[2]
                if f in BOUNCE_BITS:
                    e.bounce = (e.bounce | BOUNCE_BITS[f]) if v else (e.bounce & ~BOUNCE_BITS[f])
                elif f in DEPRECATED_BOUNCE:
                    e.bounce &= ~(TYPEMASK | USESEE)
                    if v:
                        e.bounce |= dict(BOUNCE_TYPES)[DEPRECATED_BOUNCE[f]]
                elif f in DEPRECATED_GRAVITY:
                    e.gravity = DEPRECATED_GRAVITY[f] if v else 1.0
                elif f in fl_ok:
                    e.flags[f] = v
                elif f in fl_dummy:
                    pass
                else:
                    e.notes.append('flag %s%s (%s) is not an engine flag: dropped' % ('+' if v else '-', f, a.name))
                continue
            _, nm, args = ent
            if nm == 'bouncetype' and args:
                bt = args[0].strip('"').lower()
                types = {x.lower(): b for x, b in BOUNCE_TYPES}
                if bt in types:
                    e.bounce = (e.bounce & ~(TYPEMASK | USESEE)) | types[bt]
            elif nm in ('damagefactor', 'painchance'):
                tab = e.dmgf if nm == 'damagefactor' else e.painc
                if len(args) >= 2:
                    tab[args[0].strip('"').lower()] = (args[0].strip('"'), args[1])
                elif args:
                    e.props[nm] = args
            elif nm == 'scale' and args:
                e.sx = e.sy = args[0]
            elif nm == 'xscale' and args:
                e.sx = args[0]
            elif nm == 'yscale' and args:
                e.sy = args[0]
            elif nm == 'gravity' and args:
                e.gravity = fnum(args[0], 1.0)
            else:
                e.props[nm] = args
    return e


def fnum(s, d):
    try:
        return float(str(s).strip('"'))
    except ValueError:
        return d


def zq(s):
    s = str(s)
    if s.startswith('"'):
        return s
    return '"%s"' % s.replace('"', '')


# The properties a phase 3 class carries, in ZScript form. Anything else BD sets is listed in the summary and dropped.
NUM_PROPS = ('radius', 'height', 'speed', 'mass', 'health', 'alpha', 'bouncefactor', 'wallbouncefactor', 'bouncecount',
             'projectilepassheight', 'deathheight', 'burnheight', 'maxstepheight', 'friction')
STR_PROPS = ('deathsound', 'seesound', 'painsound', 'bouncesound', 'activesound', 'wallbouncesound', 'damagetype',
             'species', 'decal', 'renderstyle', 'bloodcolor', 'obituary')
LIST_PROPS = ('translation', 'bloodtype')
IGNORED_PROPS = {'obituary', 'tag', 'game', 'spawnid', 'conversationid'}
# Actor's defaults (actor.zs Default): a flier subclass resets what its gib sets and the flier does not.
ACTOR_DEFAULTS = {'radius': '20', 'height': '16', 'speed': '0', 'mass': '100', 'health': '1000', 'alpha': '1',
                  'bouncefactor': '0.7', 'wallbouncefactor': '0.75', 'bouncecount': '-1', 'renderstyle': '"Normal"',
                  'deathsound': '""', 'seesound': '""', 'painsound': '""', 'bouncesound': '""', 'activesound': '""',
                  'damagetype': '"None"', 'species': '"None"', 'decal': '"None"', 'painchance': '0',
                  'projectilepassheight': '0', 'wallbouncesound': '""'}


def default_lines(e, expr, gib=None):
    """ZScript Default lines for an effective set. With `gib` (a flier subclass of it), whatever the gib sets and the
    flier does not is reset to Actor's default, and the typed damage factors and pain chances are NOT written: the
    flier inherits the gib's tables (it needs them once landed; RSQGO_FlyFactor covers its flight)."""
    L = []
    p = e.props
    for nm in NUM_PROPS:
        if nm in p and p[nm]:
            L.append('%s %s;' % (nm.capitalize(), expr(p[nm][0])))
        elif gib is not None and nm in gib.props and nm in ACTOR_DEFAULTS:
            L.append('%s %s;' % (nm.capitalize(), ACTOR_DEFAULTS[nm]))
    if e.gravity is not None:
        L.append('Gravity %s;' % num(e.gravity))
    elif gib is not None and gib.gravity is not None:
        L.append('Gravity 1;')
    if e.sx is not None or e.sy is not None:
        if e.sx == e.sy:
            L.append('Scale %s;' % expr(e.sx))
        else:
            if e.sx is not None:
                L.append('XScale %s;' % expr(e.sx))
            if e.sy is not None:
                L.append('YScale %s;' % expr(e.sy))
    elif gib is not None and (gib.sx is not None or gib.sy is not None):
        L.append('Scale 1;')
    for nm in STR_PROPS:
        if nm in IGNORED_PROPS or (nm == 'bloodcolor' and nm in p and p[nm] and not p[nm][0].strip('"')):
            continue                            # (BD writes bloodcolor "": no colour, which is the default)
        if nm == 'bloodcolor' and gib is not None:
            continue                            # a flier keeps its gib's blood (Class.fly_blood: its own in flight)
        if nm in p and p[nm]:
            L.append('%s %s;' % ({'renderstyle': 'RenderStyle', 'deathsound': 'DeathSound', 'seesound': 'SeeSound',
                                   'painsound': 'PainSound', 'bouncesound': 'BounceSound', 'activesound': 'ActiveSound',
                                   'wallbouncesound': 'WallBounceSound', 'damagetype': 'DamageType',
                                   'species': 'Species', 'decal': 'Decal', 'bloodcolor': 'BloodColor'}[nm], zq(p[nm][0])))
        elif gib is not None and nm in gib.props and nm in ACTOR_DEFAULTS:
            L.append('%s %s;' % ({'renderstyle': 'RenderStyle', 'deathsound': 'DeathSound', 'seesound': 'SeeSound',
                                   'painsound': 'PainSound', 'bouncesound': 'BounceSound', 'activesound': 'ActiveSound',
                                   'wallbouncesound': 'WallBounceSound', 'damagetype': 'DamageType',
                                   'species': 'Species', 'decal': 'Decal'}.get(nm, nm), ACTOR_DEFAULTS[nm]))
    for nm in LIST_PROPS:
        if nm == 'bloodtype' and gib is not None:
            continue
        if nm in p and p[nm]:
            L.append('%s %s;' % ({'translation': 'Translation', 'bloodtype': 'BloodType'}[nm],
                                 ', '.join(zq(x) for x in p[nm])))
        elif gib is not None and nm == 'translation' and 'translation' in gib.props:
            L.append('Translation "0:255=0:255";')
    if 'damage' in p and p['damage']:
        d = p['damage'][0]
        if d.startswith('('):
            L.append('DamageFunction %s;' % expr(d))
        else:
            L.append('Damage %s;' % expr(d))
    if 'painchance' in p and p['painchance']:
        L.append('PainChance %s;' % expr(p['painchance'][0]))
    elif gib is not None:
        L.append('PainChance 0;')
    if gib is None:
        if 'damagefactor' in p and p['damagefactor']:
            L.append('DamageFactor %s;' % expr(p['damagefactor'][0]))
        for _, (sp, v) in sorted(e.dmgf.items()):
            L.append('DamageFactor %s, %s;' % (zq(sp), expr(v)))
        for _, (sp, v) in sorted(e.painc.items()):
            L.append('PainChance %s, %s;' % (zq(sp), expr(v)))
    # bounce: the named type that gives the type bits (and the old flags' "use the see sound"), then bit fixes
    want = e.bounce
    # the named type closest to the wanted type bits with the same see-sound fallback (only a type can set that bit:
    # +DOOMBOUNCE -BOUNCEONFLOORS is "DoomCompat" then -BOUNCEONFLOORS), the remaining bits fixed by flags below
    tw = want & (TYPEMASK | USESEE)
    cands = [(bin((bits ^ tw) & TYPEMASK).count('1'), n, nm, bits) for n, (nm, bits) in enumerate(BOUNCE_TYPES)
             if (bits & USESEE) == (tw & USESEE)]
    _, _, base_name, base_bits = min(cands)
    if base_name != 'None' or gib is not None:
        L.append('BounceType "%s";' % base_name)
    # BounceType keeps the bits outside the type (CANBOUNCEWATER, EXPLODEONWATER ...): a flier starts from its gib's
    actual = base_bits | ((gib.bounce & ~(TYPEMASK | USESEE)) if gib is not None else 0)
    for f, bit in sorted(BOUNCE_BITS.items()):
        if (want & bit) != (actual & bit):
            L.append('%sBOUNCE_FLAG_%s;' % ('+' if want & bit else '-', f))
    return L


def blood_of(e):
    """(BloodType, BloodType2, BloodType3, BloodColor) of an effective set, as the engine fills them
    (thingdef_properties.cpp bloodtype: a missing slot repeats the last one given; Actor's default triple)."""
    b = [x.strip('"') for x in e.props.get('bloodtype') or []]
    tri = ('Blood', 'BloodSplatter', 'AxeBlood') if not b else tuple((b + [b[-1]] * 3)[:3])
    c = (e.props.get('bloodcolor') or [''])[0].strip('"').strip()
    return tri + (c.lower(),)


def num(x):
    s = ('%.6f' % x).rstrip('0').rstrip('.')
    return s if s not in ('', '-0') else '0'


# ------------------------------------------------------------------ expressions
EXPR_TOK = re.compile(r'"(?:[^"\\]|\\.)*"|\d+\.?\d*(?:[eE][-+]?\d+)?|\.\d+|[A-Za-z_]\w*|==|!=|<=|>=|&&|\|\||<<|>>|\S')


def expr(e):
    """A DECORATE numeric expression in ZScript, or Unsupported."""
    e = str(e).strip()
    toks = EXPR_TOK.findall(e)
    out, i = [], 0
    while i < len(toks):
        t = toks[i]
        if re.match(r'^[A-Za-z_]', t):
            tl = t.lower()
            if tl in ID_MAP:
                out.append(ID_MAP[tl])
            elif tl in ('random', 'frandom', 'random2'):
                out.append(tl)
                if i + 1 < len(toks) and toks[i + 1] == '[':
                    j = toks.index(']', i + 1) if ']' in toks[i + 1:] else i + 1
                    out.append(''.join(toks[i + 1:j + 1]))
                    i = j
            elif tl in ID_OK:
                out.append(tl)
            elif CONST_RE.match(t):
                out.append(t.upper())
            else:
                raise Unsupported('expression "%s" (%s)' % (e, t))
        elif t.startswith('"'):
            raise Unsupported('string in expression "%s"' % e)
        else:
            out.append(t)
        i += 1
    s = ''
    for t in out:
        if s and (re.match(r'^[\w.]', t) and re.match(r'[\w.)]$', s)):
            s += ' '
        elif t in ('==', '!=', '<=', '>=', '&&', '||', '<', '>', '+', '*', '/', '|', '&', '<<', '>>', '%', '?', ':') \
                or (t == '-' and s and re.search(r'[\w.)]$', s)):
            s += ' ' + t + ' '
            continue
        elif t == ',':
            s += ', '
            continue
        s += t
    return re.sub(r'\s+', ' ', s).strip()


def lit0(a):
    """True if a DECORATE argument is a literal zero (or absent)."""
    if a is None or str(a).strip() == '':
        return True
    try:
        return float(str(a).strip()) == 0.0
    except ValueError:
        return False


# ------------------------------------------------------------------ a class's state graph
class Graph:
    """The reachable states of one class (leaf), flattened through its chain, and what each one does."""

    def __init__(self, world, key):
        self.w, self.key = world, key
        self.nodes = set()
        self.runtime = {}          # BD label (lower) -> resolved ('st', node) | ('flow', f) | None
        self.entries = {}          # BD label (lower) -> resolved
        self.calls = {}            # node -> [(name, args)]

    def state(self, node):
        return self.w.cls[node[0]].states.S[node[1]]

    def label(self, lb):
        r = self.w.find_label(self.key, lb)
        if r is None:
            return None
        k, ref = r
        if ref[0] == 'idx':
            st = self.w.cls[k].states
            return ('st', (k, ref[1])) if ref[1] < len(st.S) else ('flow', ('stop',))
        return self.flow(k, ref[1])

    def flow(self, d, f, depth=0):
        if f[0] == 'goto' and depth < 16:
            g = self.w.goto(d, f[1])
            if g is None:
                return ('flow', ('stop',))
            if g[0] == 'flow':
                return self.flow(g[1], g[2], depth + 1)
            st = self.w.cls[g[0]].states
            return ('st', g) if g[1] < len(st.S) else ('flow', ('stop',))
        if f[0] == 'loop':
            st = self.w.cls[d].states
            return ('st', (d, f[1])) if st and f[1] < len(st.S) else ('flow', ('stop',))
        return ('flow', ('stop',) if f[0] in ('stop', 'fail', 'goto') else f)

    def succ(self, node):
        d, i = node
        st = self.w.cls[d].states
        nx = st.nxt[i]
        if nx[0] == 'seq':
            return ('st', (d, i + 1)) if i + 1 < len(st.S) else ('flow', ('stop',))
        if nx[0] == 'loop':
            return ('st', (d, nx[1]))
        if nx[0] == 'goto':
            return self.flow(d, nx)
        if nx[0] == 'wait':
            return ('wait',)
        return ('flow', ('stop',))

    def all_labels(self):
        out = []
        for k in self.w.chain(self.key):
            st = self.w.cls[k].states
            if st:
                for lb in st.order:
                    if lb not in out:
                        out.append(lb)
        return out


# ------------------------------------------------------------------ the transpiler
class Plan:
    def __init__(self, idx, row):
        self.idx, self.row = idx, row
        self.key, self.name, self.cat = row['key'], row['class'], row['label']
        self.zname = PREFIX + row['class']
        self.left = None
        self.eff = None
        self.g = None
        self.sites = {}            # node -> (G key, mode args) become sites found by the scan
        self.become = {}           # node -> G key (accepted)
        self.gib = None            # flier: the gib key it subclasses
        self.chflags = set()       # flags A_ChangeFlag touches in reachable states
        self.shootable = False
        self.notes = []
        self.longs = set()         # nodes wrapped by RSQGO_LongRest
        self.forever = set()       # nodes whose tics become -1
        self.holds = set()         # 1000+ tic nodes with an action: keep their tics, hold (-1) once the action ran
        self.kids = set()          # BD classes spawned (names)
        self.particles = set()     # phase 1 classes whose spawns become particle calls
        self.lines = []
        self.canon = None
        self.rp = None             # the runtime parent (RSQGO_Limb / RSQGO_Chunk / RSQGO_Casing)
        self.chainb = []           # the shared bases above it, nearest first (Gen.share)


class Base:
    """A shared base class: the states one BD base class gives its generated classes (Gen.share)."""

    def __init__(self, idx, name, rp, key):
        self.idx, self.zname, self.rp, self.key = idx, name, rp, key
        self.parent = None
        self.nodes, self.sig, self.members, self.labels, self.lines = [], {}, [], {}, []
        self.used = False

    def holder_of(self, nd):
        b = self
        while b is not None:
            if nd in b.sig:
                return b
            b = b.parent
        return None

    def inherited_labels(self):
        return self.parent.all_labels() if self.parent else {}

    def all_labels(self):
        d = self.inherited_labels()
        d.update(self.labels)
        return d

    def mark_used(self):
        b = self
        while b is not None:
            b.used = True
            b = b.parent


class Gen:
    def __init__(self, bd, xm):
        self.bd, self.xm = bd, xm
        self.world, self.cat, self.rows = gen_gore.build(bd, xm)
        self.fl_ok, self.fl_dep, self.fl_dummy = engine_flags()
        packs = [(bd, 'BD'), (xm, 'XMVE')]
        self.flats = cards.liquid_flats(packs)
        self.liquid_tokens = sorted(self.flats)
        self.models = read_modeldefs(packs)
        p3 = [r for r in self.rows if r['label'] in PHASE3 and r['owner'] == 'gore']
        self.plans = [Plan(i, r) for i, r in enumerate(p3)]
        self.by_key = {p.key: p for p in self.plans}
        self.p1 = {r['key'] for r in self.rows if r['label'] in cards.PHASE1 and r['owner'] == 'gore'}

    # ---------------------------------------------------------- pass 1: what each class reaches and does
    def scan(self, p):
        w = self.world
        p.eff = effective(w, p.key, self.fl_ok, self.fl_dep, self.fl_dummy)
        p.notes += p.eff.notes
        g = Graph(w, p.key)
        p.g = g
        if w.states_of(p.key) is None:
            raise Unsupported('no States in its chain')
        for k in w.chain(p.key):
            if re.search(r'\bnodelay\b', props_states_text(w.cls[k]), re.I):
                raise Unsupported('a NoDelay state in %s (decorate.py does not keep it)' % w.cls[k].name)
        p.shootable = bool(p.eff.flags.get('SHOOTABLE'))
        labels = g.all_labels()
        todo = []

        def add_entry(lb):
            if lb in g.entries:
                return
            r = g.label(lb)
            g.entries[lb] = r
            if r and r[0] == 'st':
                todo.append(r[1])

        for lb in labels:
            if lb in ENTRY_ALWAYS:
                add_entry(lb)
        changed = True
        while changed:
            changed = False
            while todo:
                node = todo.pop()
                if node in g.nodes:
                    continue
                g.nodes.add(node)
                s = g.state(node)
                if s['action'].strip().startswith('{'):
                    raise Unsupported('an anonymous action block')
                cl = top_calls(s['action'])
                g.calls[node] = cl
                for name, args in cl:
                    for tgt in self.jump_targets(name, args):
                        if isinstance(tgt, int):
                            nd = (node[0], node[1] + tgt)
                            if nd[1] < len(w.cls[nd[0]].states.S):
                                todo.append(nd)
                        else:
                            lb = tgt.lower()
                            if lb not in g.runtime:
                                r = g.label(lb)
                                g.runtime[lb] = r
                                if r and r[0] == 'st':
                                    todo.append(r[1])
                    if name.lower() == 'a_changeflag' and args:
                        f = cards.unq(args[0]).upper()
                        p.chflags.add(f)
                        if f == 'SHOOTABLE' and not lit0(args[1] if len(args) > 1 else '0'):
                            p.shootable = True
                sc = g.succ(node)
                if sc[0] == 'st':
                    todo.append(sc[1])
            if p.shootable:
                for lb in labels:
                    if any(lb == e or (e.endswith('.') and lb.startswith(e)) for e in ENTRY_SHOOTABLE):
                        if lb not in g.entries:
                            add_entry(lb)
                            changed = True
        if 'spawn' not in g.entries:
            raise Unsupported('no Spawn label')
        # translate once now, to find what cannot be reproduced and the become sites
        for node in sorted(g.nodes):
            for name, args in g.calls[node]:
                self.call(p, node, name, args, None)

    def jump_targets(self, name, args):
        n = name.lower()
        out = []
        if n == 'a_jump':
            out = args[1:]
        elif n in ('a_jumpif', 'a_jumpifhealthlower'):
            out = args[1:2]
        elif n in ('a_checkfloor', 'a_checkceiling', 'a_checksight'):
            out = args[:1]
        elif n == 'a_jumpifinventory':
            out = args[2:3]
        elif n.startswith('acs_') and args and cards.unq(args[0]).lower() == 'bdcheckjanitor3':
            out = ['"NoColision"']
        res = []
        for a in out:
            a = a.strip()
            if a.startswith('"'):
                res.append(cards.unq(a))
            else:
                try:
                    res.append(int(float(a)))
                except ValueError:
                    pass
        return res

    # ---------------------------------------------------------- one call, in ZScript (lab=None: scan only)
    def call(self, p, node, name, args, lab):
        n = name.lower()
        a = list(args) + [''] * 12

        def L(x):
            """A label argument: a quoted BD label or a state offset."""
            x = x.strip()
            if lab is None:
                return '"?"'
            if x.startswith('"'):
                return lab(cards.unq(x).lower(), None)
            return lab(None, int(float(x)))

        def E(x, d='0'):
            x = str(x).strip()
            return expr(x) if x != '' else d

        def C(x):
            cls = cards.unq(x)
            if not re.match(r'^[A-Za-z0-9_]+$', cls):
                raise Unsupported('class name %r' % cls)
            p.kids.add(cls)
            return "'%s'" % cls

        if n in SPAWNS:
            cls = cards.unq(a[0]) if a[0] else ''
            if not cls:
                raise Unsupported('%s without a class' % name)
            ck = cls.lower()
            if n in ('a_spawnitem', 'a_spawnitemex') and lab is None:
                site = self.become_site(p, node, n, a)
                if site:
                    p.sites[node] = site
            if lab is not None and node in p.become:
                site = p.sites[node]
                gk = p.become[node]
                gp = self.by_key[gk]
                mode = self.spawn_mode(gp)
                return 'RSQGO_Become(%d, %s, %s)' % (mode, 'true' if site[1] else 'false', 'true' if site[2] else 'false'), True
            if ck in self.p1:
                p.particles.add(cls)
            if n in ('a_custommissile', 'a_spawnprojectile'):
                if a[6].strip() and a[6].strip().upper() not in ('AAPTR_TARGET', '0', 'AAPTR_DEFAULT'):
                    raise Unsupported('%s with a pointer %s' % (name, a[6]))
                fl = E(a[4])
                if n == 'a_spawnprojectile':
                    return 'RSQGO_Missile(%s, %s, %s, %s, %s, %s, false)' % (C(a[0]), E(a[1], '32'), E(a[2]), E(a[3]), fl, E(a[5])), False
                return 'RSQGO_Missile(%s, %s, %s, %s, %s, %s, true)' % (C(a[0]), E(a[1], '32'), E(a[2]), E(a[3]), fl, E(a[5])), False
            if n == 'a_spawnitem':
                tr = 'true' if not lit0(a[4]) and a[4].strip().lower() != 'false' else 'false'
                return 'RSQGO_Item(%s, %s, %s, %s)' % (C(a[0]), E(a[1]), E(a[2]), tr), False
            return 'RSQGO_ItemEx(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)' % (
                C(a[0]), E(a[1]), E(a[2]), E(a[3]), E(a[4]), E(a[5]), E(a[6]), E(a[7]), E(a[8]), E(a[9])), False
        if n == 'a_queuecorpse':
            return '', False                    # our ring takes it when it parks
        if n == 'a_fall':
            return 'A_NoBlocking()', False
        if n in PASS:
            return '%s(%s)' % (PASS[n], ', '.join(E(x) for x in args if str(x).strip() != '')), False
        if n == 'a_chase':
            if any(cards.unq(x) for x in args[:2]) or len(args) > 2:
                raise Unsupported('A_Chase with states or flags')
            return 'A_Chase(null, null)', False
        if n in ('a_playsound', 'a_startsound'):
            snd = zq(cards.unq(a[0]))
            if n == 'a_startsound':
                return 'A_StartSound(%s)' % ', '.join([snd] + [E(x) for x in args[1:] if str(x).strip()]), False
            # A_PlaySound(sound, slot = CHAN_BODY, volume, looping, attenuation, local, pitch) as the engine runs it
            # (s_doomsound.cpp A_PlaySound): looping ORs in CHANF_LOOP | CHANF_NOSTOP (CHANF_LOOPING), local CHANF_LOCAL
            ch = a[1].strip()
            try:
                chv = int(float(ch)) if ch else 4
            except ValueError:
                raise Unsupported('A_PlaySound channel %s' % ch)
            loop = not lit0(a[3]) and a[3].strip().lower() != 'false'
            local = not lit0(a[5]) and a[5].strip().lower() != 'false'
            fl = ([str(chv & ~7)] if chv & ~7 else []) + (['CHANF_LOOPING'] if loop else []) + (['CHANF_LOCAL'] if local else [])
            parts = [snd, 'CHAN_BODY' if chv & 7 == 4 else str(chv & 7), ' | '.join(fl) or '0', E(a[2], '1'),
                     E(a[4], 'ATTN_NORM')]
            if a[6].strip() and not lit0(a[6]):
                parts.append(E(a[6]))
            return 'A_StartSound(%s)' % ', '.join(parts), False
        if n == 'a_changeflag':
            f = cards.unq(a[0]).upper()
            v = 'false' if lit0(a[1]) or a[1].strip().lower() == 'false' else 'true'
            if f == 'NOBLOCKMAP':
                return 'A_ChangeLinkFlags(%d)' % (v == 'true'), False
            if f == 'NOSECTOR':
                return 'A_ChangeLinkFlags(FLAG_NO_CHANGE, %d)' % (v == 'true'), False
            if f in DEPRECATED_GRAVITY:
                return '{ gravity = %s; }' % (num(DEPRECATED_GRAVITY[f]) if v == 'true' else '1'), False
            if f in self.fl_dummy:
                return '', False
            if f in BOUNCE_BITS or f in self.fl_ok:
                return '{ b%s = %s; }' % (f, v), False
            raise Unsupported('A_ChangeFlag of %s' % f)
        if n == 'a_givetotarget':
            return 'RSQGO_GiveTarget(%s, %s)' % (C(a[0]), E(a[1], '1')), False
        if n == 'a_giveinventory':
            return 'RSQGO_GiveSelf(%s, %s)' % (C(a[0]), E(a[1], '1')), False
        if n == 'a_jump':
            labs = [L(x) for x in args[1:]]
            labs = [x for x in labs if x is not None]
            if lab is not None and not labs:
                return '', False
            return 'A_Jump(%s, %s)' % (E(a[0]), ', '.join(labs or ['"?"'])), True
        if n == 'a_jumpif':
            t = L(a[1])
            if t is None:
                return '', False
            return 'A_JumpIf(%s, %s)' % (E(a[0]), t), True
        if n in ('a_checkfloor', 'a_checkceiling', 'a_checksight'):
            t = L(a[0])
            if t is None:
                return '', False
            return '%s(%s)' % ({'a_checkfloor': 'A_CheckFloor', 'a_checkceiling': 'A_CheckCeiling',
                                'a_checksight': 'A_CheckSight'}[n], t), True
        if n == 'a_jumpifhealthlower':
            t = L(a[1])
            if t is None:
                return '', False
            if a[2].strip():
                raise Unsupported('A_JumpIfHealthLower with a pointer')
            return 'A_JumpIfHealthLower(%s, %s)' % (E(a[0]), t), True
        if n == 'a_jumpifinventory':
            item = cards.unq(a[0])
            t = L(a[2])
            if a[3].strip():
                raise Unsupported('A_JumpIfInventory with a pointer')
            if t is None:
                return '', False
            il = item.lower()
            if il in self.flats:
                return 'RSQGO_JumpIfLiquid(%d, %s)' % (self.liquid_tokens.index(il), t), True
            if il == 'lowgraphicsmode':
                return 'RSQGO_JumpIfLowGfx(%s, %s)' % (E(a[1]), t), True
            p.kids.add(item)
            return "RSQGO_JumpIfInv('%s', %s, %s)" % (item, E(a[1]), t), True
        if n.startswith('acs_'):
            sc = cards.unq(a[0]).lower() if a[0] else ''
            if n not in ('acs_namedexecutealways', 'acs_namedexecute'):
                raise Unsupported('%s' % name)
            if sc == 'bd_checkifoverliquid':
                return 'RSQGO_LiquidCheck()', False
            if sc == 'bdcheckjanitor':
                return 'RSQGO_Janitor()', False
            if sc == 'bdcheckjanitor2':
                return 'RSQGO_Janitor2()', False
            if sc == 'bdcheckjanitor3':
                return 'RSQGO_Janitor3(%s)' % L('"NoColision"'), True
            # any other BD script: run as BD runs it (by name: no class constant)
            return 'ACS_NamedExecuteAlways(%s)' % ', '.join([zq(cards.unq(a[0]))] + [E(x) for x in args[1:] if str(x).strip()]), False
        raise Unsupported('the call %s' % name)

    # ---------------------------------------------------------- becoming
    def become_site(self, p, node, n, a):
        """(G key, keep scale, keep translation) if this spawn is "the same actor, now as G": an exact-position spawn of
        a phase 3 class followed by nothing but frames until Stop."""
        gk = cards.unq(a[0]).lower()
        if gk not in self.by_key or self.by_key[gk].cat == 'casing':
            return None
        keep_scale = keep_trans = False
        if n == 'a_spawnitem':
            if not (lit0(a[1]) and lit0(a[2])):
                return None
            keep_trans = not lit0(a[4]) and a[4].strip().lower() != 'false'
        else:
            if not all(lit0(a[k]) for k in range(1, 8)) or a[9].strip() not in ('', '0'):
                return None
            for tok in re.split(r'\s*\|\s*', a[8].strip()):
                tk = tok.upper()
                if tk in ('', '0', 'SXF_NOCHECKPOSITION'):
                    continue
                if tk == 'SXF_TRANSFERSCALE':
                    keep_scale = True
                elif tk == 'SXF_TRANSFERTRANSLATION':
                    keep_trans = True
                else:
                    return None
        g = p.g
        cur = node
        for _ in range(12):
            sc = g.succ(cur)
            if sc[0] == 'flow':
                return (gk, keep_scale, keep_trans) if sc[1][0] == 'stop' else None
            if sc[0] != 'st':
                return None
            cur = sc[1]
            if g.state(cur)['action'].strip():
                return None
        return None

    def spawn_mode(self, gp):
        """How RSQGO_Become enters G's Spawn: 0 its first state, 1 the state after it (BD never runs a spawn state's
        first action without NoDelay, and a 0-tic first state passes on the first tic), 2 the first state without its
        action (a first state with tics and an action)."""
        st = self.world.cls[self.world.states_of(gp.key)].states
        r = self.world.find_label(gp.key, 'spawn')
        k, ref = r
        s = self.world.cls[k].states.S[ref[1]]
        if not s['action'].strip():
            return 0
        if s['tics'][0] == 0 and s['tics'][1] == 0:
            return 1
        return 2

    def resolve_becoming(self):
        ok = {p.key for p in self.plans if not p.left}
        # a gib may parent fliers only if its own runtime jumps never name Spawn (a flier's Spawn is its own)
        def gib_ok(gk):
            gp = self.by_key.get(gk)
            # only into a shootable gib: the landed limb (design 2.3); other chunks keep BD's spawn-and-stop
            return (gp is not None and not gp.left and gp.shootable and 'spawn' not in gp.g.runtime
                    and gp.cat != 'casing')
        cand = {}
        for p in self.plans:
            if p.left:
                continue
            gs = {s[0] for s in p.sites.values() if s[0] != p.key and s[0] in ok}
            if len(gs) == 1:
                gk = gs.pop()
                if gib_ok(gk) and not self.flier_pain(p):
                    cand[p.key] = gk
            elif gs:
                if len({x for x in gs if gib_ok(x)}) > 1:
                    p.notes.append('lands as different limbs (%s): keeps spawning them' % ', '.join(sorted(gs)))
        # a class that is a gib for a flier cannot itself be a flier (its F_ labels would shadow what fliers need)
        targets = set(cand.values())
        for fk in sorted(cand):
            if fk in targets:
                self.by_key[fk].notes.append('both a gib other fliers become and a flier: keeps spawning its gib')
                del cand[fk]
        targets = set(cand.values())
        for p in self.plans:
            if p.left:
                continue
            p.gib = cand.get(p.key)
            for node, s in p.sites.items():
                if p.gib and s[0] == p.gib:
                    p.become[node] = s[0]
                elif s[0] == p.key and not p.gib and p.shootable:
                    p.become[node] = s[0]      # a limb landing again (Landz): the same actor starts over

    def flier_pain(self, p):
        """A flier that has its own pain (pain chance and a Pain state) cannot borrow its gib's Pain."""
        pc = p.eff.props.get('painchance')
        has = any(lb.startswith('pain') for lb in p.g.all_labels())
        return bool(pc and fnum(pc[0], 0) > 0 and has)

    # ---------------------------------------------------------- rests that tick forever
    def rest_rules(self, p):
        g = p.g
        for node in g.nodes:
            s = g.state(node)
            if s['tics'][0] >= LONG_FOREVER and s['tics'][0] == s['tics'][1]:
                # with an action (LimbBase's 1900-tic spot loop) the action must still run when BD first runs it:
                # never on the first spawn state (no NoDelay), so a -1 there would drop it for good
                (p.holds if self.effective_action(p, node) else p.forever).add(node)
        for node in sorted(g.nodes):
            if node in p.forever or node in p.holds:
                continue
            # a static loop: frames with no action, one sprite+frame, back to the start
            s0 = g.state(node)
            if s0['tics'][0] > 0 and s0['tics'][0] == s0['tics'][1] and not self.effective_action(p, node):
                cur, ok = node, True
                for _ in range(64):
                    sc = g.succ(cur)
                    if sc[0] != 'st':
                        ok = False
                        break
                    cur = sc[1]
                    s = g.state(cur)
                    if self.effective_action(p, cur) or s['tics'][0] <= 0 or (s['sprite'], s['frame']) != (s0['sprite'], s0['frame']):
                        ok = False
                        break
                    if cur == node:
                        break
                else:
                    ok = False
                if ok and cur == node and s0['sprite'] not in ('####',):
                    p.forever.add(node)
                    continue
            # a long state on a cycle
            if s0['tics'][0] >= LONG_LOOP and self.on_cycle(p, node):
                p.longs.add(node)

    def effective_action(self, p, node):
        for name, args in p.g.calls.get(node, []):
            if name.lower() != 'a_queuecorpse':
                return True
        return False

    def on_cycle(self, p, start):
        g = p.g
        seen, stack = set(), []

        def nexts(node):
            out = []
            if g.state(node)['tics'][0] < 0:
                return out                      # a -1 frame never moves on: no cycle through it
            sc = g.succ(node)
            if sc[0] == 'st':
                out.append(sc[1])
            elif sc[0] == 'wait':
                out.append(node)
            for name, args in g.calls.get(node, []):
                for t in self.jump_targets(name, args):
                    if isinstance(t, int):
                        out.append((node[0], node[1] + t))
                    else:
                        r = g.runtime.get(t.lower())
                        if r and r[0] == 'st':
                            out.append(r[1])
            return out
        stack = nexts(start)
        while stack:
            nd = stack.pop()
            if nd == start:
                return True
            if nd in seen or nd not in g.nodes:
                continue
            seen.add(nd)
            stack += nexts(nd)
        return False

    # ---------------------------------------------------------- pass 2: the ZScript class
    def emit(self, p):
        """The class's reachable states in canonical form (p.canon); render() writes them, into the class itself or into
        a shared base (share()). A reference to a state is a placeholder ref(node), named by whichever class holds it."""
        g = p.g
        w = self.world
        flier = p.gib is not None
        order_k = {k: n for n, k in enumerate(reversed(w.chain(p.key)))}
        nodes = sorted(g.nodes, key=lambda nd: (order_k.get(nd[0], 99), nd[1]))
        labels = {}                 # label -> ('st', node) | ('stop',), in emission order

        def named(lb):
            return lb if (lb == 'spawn' or not flier) else FLIER_PREFIX + lb

        def lab_for(nd):
            def lab(lb, off):
                if lb is not None:
                    r = g.runtime.get(lb)
                    if r is None:
                        return ('"%s"' % lb.capitalize()) if lb in ACTOR_LABELS else None
                    nm = named(lb)
                    if r[0] == 'flow':
                        labels.setdefault(nm, ('stop',))
                    return '"%s"' % nm
                t = (nd[0], nd[1] + off)
                return ('"%s"' % ref(t)) if t in g.nodes else None
            return lab

        for src in (g.entries, g.runtime):
            for lb, r in sorted(src.items()):
                if r is None:
                    continue
                nm = named(lb)
                if nm not in labels:
                    labels[nm] = ('st', r[1]) if r[0] == 'st' else ('stop',)
        text, succ = {}, {}
        for nd in nodes:
            text[nd] = self.state_line(p, nd, g.state(nd), lab_for(nd))
            sc = g.succ(nd)
            succ[nd] = ('st', sc[1]) if sc[0] == 'st' else ('wait',) if sc[0] == 'wait' else ('stop',)
        for nm in labels:
            base = nm.split('.')[0].lower()
            if base in ZS_FLOW_WORDS or not re.match(r'^[A-Za-z_][\w.]*$', nm):
                raise Unsupported('a state label named %s' % nm)
        # labels in today's order: the ones on states first (by state), then the ones that are just "stop"
        st_l = [nm for nm, v in labels.items() if v[0] == 'st']
        stop_l = sorted(nm for nm, v in labels.items() if v[0] == 'stop')
        p.canon = {'nodes': nodes, 'text': text, 'succ': succ, 'labels': {nm: labels[nm] for nm in st_l + stop_l}}
        return p.canon

    # ---------------------------------------------------------- shared bases (the flattening's copies, compiled once)
    def share(self):
        """BD keeps shared sequences in base classes (LimbBase, TinyGib, XDeath2...). Flattening copied them into every
        class; here they go back into one generated base per BD base, RSQGO_GB_<BD base>, which the classes under it
        inherit. A state goes into a base only if it reads the same, character for character, in every class under that
        base that reaches it (rewrites included: becoming, rests, labels), and everything it goes to is in that base or
        above it. A base defines a label only where every class under it defines that label to the same state. So every
        class runs exactly the states it ran flattened (an unqualified jump label resolves in the actor's class at run
        time, and every class keeps its own label table). A base has no Default and no overrides: each class still
        writes its whole Default. A flier's base sits between its gib and it."""
        w = self.world
        self.bases = []
        cand = [p for p in self.plans if not p.left]
        for p in self.plans:
            # what the class extends without a base: its runtime class, or (a flier) its gib; a base sits in between
            p.rp = self.by_key[p.gib].zname if p.gib else self.runtime_parent(p)
            p.chainb = []
        groups = {}
        for p in cand:
            for a in w.chain(p.key):
                groups.setdefault((p.rp, a), []).append(p)
        valid = {k: v for k, v in groups.items() if len(v) >= 2}
        # top-down: a base's parent base is the nearest valid one above its BD class
        keys = sorted(valid, key=lambda k: (len(w.chain(k[1])), k[1], k[0]))
        info = {}
        for k in keys:
            rp, a = k
            parent = None
            for up in w.chain(a)[1:]:
                if (rp, up) in info:
                    parent = (rp, up)
                    break
            above = []
            q = parent
            while q:
                above.append(q)
                q = info[q]['parent']
            held_above = {}
            for q in above:
                for nd in info[q]['nodes']:
                    held_above[nd] = q
            members = valid[k]
            chain_a = set(w.chain(a))
            cn = {}
            ok = set()
            for m in members:
                c = m.canon
                for nd in c['nodes']:
                    if nd[0] not in chain_a or nd in held_above:
                        continue
                    sig = (c['text'][nd], c['succ'][nd])
                    if nd not in cn:
                        cn[nd] = sig
                        ok.add(nd)
                    elif cn[nd] != sig:
                        ok.discard(nd)
            changed = True
            while changed:
                changed = False
                for nd in sorted(ok):
                    txt, sc = cn[nd]
                    refs = [r for r in refs_in(txt)]
                    if sc[0] == 'st':
                        refs.append(sc[1])
                    if any(r not in ok and r not in held_above for r in refs):
                        ok.discard(nd)
                        changed = True
            info[k] = {'parent': parent, 'nodes': {nd: cn[nd] for nd in ok}, 'members': members}
        # drop bases that hold nothing (their classes go to the base above), then number and name them
        live = [k for k in keys if info[k]['nodes']]

        def live_parent(k):
            q = info[k]['parent']
            while q and not info[q]['nodes']:
                q = info[q]['parent']
            return q
        counts, seen = {}, {}
        for k in live:
            counts[k[1]] = counts.get(k[1], 0) + 1
        for n, k in enumerate(live):
            rp, a = k
            seen[a] = seen.get(a, 0) + 1
            suffix = '' if counts[a] == 1 else '_%d' % seen[a]
            b = Base(n, BASE_PREFIX + w.cls[a].name + suffix, rp, a)
            lp = live_parent(k)
            b.parent = info[lp]['base'] if lp else None
            info[k]['base'] = b
            order_k = {kk: i for i, kk in enumerate(reversed(w.chain(a)))}
            b.nodes = sorted(info[k]['nodes'], key=lambda nd: (order_k.get(nd[0], 99), nd[1]))
            b.sig = info[k]['nodes']
            b.members = info[k]['members']
            self.bases.append(b)
        for p in cand:
            for a in w.chain(p.key):
                k = (p.rp, a)
                if k in info and 'base' in info[k]:
                    p.chainb.append(info[k]['base'])
            # nearest first; a base's own chain is a prefix-closed path, so this is p's parent line
        # labels: top-down; a base defines a label only if all its classes agree on it and it is not inherited as is
        for b in self.bases:
            b.labels = {}
            inh = b.inherited_labels()
            common = None
            for m in b.members:
                lab = m.canon['labels']
                common = dict(lab) if common is None else {nm: v for nm, v in common.items() if lab.get(nm) == v}
            for nm, v in (common or {}).items():
                if v[0] == 'st' and b.holder_of(v[1]) is None:
                    continue
                if inh.get(nm) != v:
                    b.labels[nm] = v
        for b in self.bases:
            b.used = False
        for p in cand:
            if p.chainb:
                p.chainb[0].mark_used()
        self.bases = [b for b in self.bases if b.used]

    def runtime_parent(self, p):
        if p.cat == 'casing':
            return 'RSQGO_Casing'
        if p.shootable or any(q.gib == p.key for q in self.plans if not q.left):
            return 'RSQGO_Limb'
        return 'RSQGO_Chunk'

    def render_class(self, nodes, labels, text_of, succ_of, holder_name, own_name, synth_needed):
        """States lines for one class: its own nodes in order, its own labels; refs named through holder_name."""
        out = []
        at = {}
        far = []
        for nm, v in labels.items():
            if v[0] == 'st':
                if v[1] in own_name:
                    at.setdefault(v[1], []).append(nm)
                else:
                    far.append((nm, v[1]))
        for i, nd in enumerate(nodes):
            out += ['%s:' % x for x in at.get(nd, [])]
            if nd in synth_needed:
                out.append('%s:' % own_name[nd])
            t = text_of(nd)
            out.append(REF_RE.sub(lambda m: holder_name(ref_node(m)), t))
            sc = succ_of(nd)
            nxt = nodes[i + 1] if i + 1 < len(nodes) else None
            if sc[0] == 'st':
                if sc[1] != nxt:
                    out.append('goto %s;' % holder_name(sc[1]))
            elif sc[0] == 'wait':
                out.append('wait;')
            else:
                out.append('stop;')
        # labels on a state a base holds: a goto to it
        bynode = {}
        for nm, nd in far:
            bynode.setdefault(nd, []).append(nm)
        for nd in sorted(bynode, key=lambda x: holder_name(x)):
            out += ['%s:' % x for x in bynode[nd]]
            out.append('goto %s;' % holder_name(nd))
        stops = [nm for nm, v in labels.items() if v[0] == 'stop']
        for nm in stops:
            out += ['%s:' % nm, 'stop;']
        return out

    def render(self):
        """p.lines for every class, and b.lines for every base, from p.canon and the bases share() made."""
        # who holds each node, per class: the nearest base on its line that holds it, else the class itself
        for b in self.bases:
            b.name_of = {}
        plans = [p for p in self.plans if not p.left]
        for p in plans:
            p.hold = {}
            for nd in p.canon['nodes']:
                for b in p.chainb:
                    if nd in b.sig:
                        p.hold[nd] = b
                        break
        # which nodes need a generated label in their holder: anything referenced that is not a fall-through
        need = {}               # holder (Base or Plan) -> set(nodes)

        def want(h, nd):
            need.setdefault(id(h), set()).add(nd)
        for p in plans:
            c = p.canon
            own = [nd for nd in c['nodes'] if nd not in p.hold]
            pos = {nd: i for i, nd in enumerate(own)}
            for nd in own:
                for r in refs_in(c['text'][nd]):
                    want(p.hold.get(r, p), r)
                sc = c['succ'][nd]
                if sc[0] == 'st' and not (sc[1] in pos and pos[sc[1]] == pos[nd] + 1):
                    want(p.hold.get(sc[1], p), sc[1])
            inh = p.chainb[0].all_labels() if p.chainb else {}
            for nm, v in c['labels'].items():
                if v[0] == 'st' and inh.get(nm) != v and v[1] in p.hold:
                    want(p.hold[v[1]], v[1])
        for b in self.bases:
            pos = {nd: i for i, nd in enumerate(b.nodes)}
            for nd in b.nodes:
                txt, sc = b.sig[nd]
                for r in refs_in(txt):
                    want(b.holder_of(r), r)
                if sc[0] == 'st' and not (sc[1] in pos and pos[sc[1]] == pos[nd] + 1):
                    want(b.holder_of(sc[1]), sc[1])
            for nm, v in b.labels.items():
                if v[0] == 'st' and v[1] not in pos:
                    want(b.holder_of(v[1]), v[1])
        # names
        for b in self.bases:
            n = 0
            for nd in b.nodes:
                if nd in need.get(id(b), ()):
                    b.name_of[nd] = 'B%d_%d' % (b.idx, n)
                    n += 1
        for b in self.bases:
            own = {nd: b.name_of.get(nd, '') for nd in b.nodes}
            b.lines = self.render_class(
                b.nodes, b.labels, lambda nd, b=b: b.sig[nd][0], lambda nd, b=b: b.sig[nd][1],
                lambda nd, b=b: b.holder_of(nd).name_of[nd], own, need.get(id(b), set()))
        for p in plans:
            c = p.canon
            own_nodes = [nd for nd in c['nodes'] if nd not in p.hold]
            names, n = {}, 0
            for nd in own_nodes:
                if nd in need.get(id(p), ()):
                    names[nd] = 'R%d_%d' % (p.idx, n)
                    n += 1
            inh = p.chainb[0].all_labels() if p.chainb else {}
            labels = {nm: v for nm, v in c['labels'].items() if inh.get(nm) != v}

            def hname(nd, p=p, names=names):
                return p.hold[nd].name_of[nd] if nd in p.hold else names[nd]
            own = {nd: names.get(nd, '') for nd in own_nodes}
            p.lines = self.render_class(own_nodes, labels, lambda nd, c=c: c['text'][nd], lambda nd, c=c: c['succ'][nd],
                                        hname, own, need.get(id(p), set()))
            if p.gib is not None:
                p.lines += ['Death:', 'TNT1 A 0 RSQGO_DeathEntry;', 'stop;']

    def state_line(self, p, nd, s, lab):
        parts = []
        for name, args in p.g.calls.get(nd, []):
            c, st = self.call(p, nd, name, args, lab)
            if c:
                parts.append((c, st))
        if len(parts) > 1:
            raise Unsupported('two calls in one state')
        code, is_state = parts[0] if parts else ('', False)
        spr, fr = s['sprite'], s['frame']
        spr_s = spr if re.match(r'^[A-Z_][A-Z0-9_]{3}$', spr) else '"%s"' % spr
        fr_s = fr if re.match(r'^[A-Z]$', fr) else '"%s"' % fr
        lo, hi = s['tics']
        if nd in p.forever:
            tics = '-1'
        elif lo == hi:
            tics = str(lo)
        else:
            tics = 'random(%d, %d)' % (lo, hi)
        if nd in p.holds:
            if code.startswith('{'):
                code = '{ %s RSQGO_Hold(); }' % code[1:-1].strip()
            elif is_state:
                code = '{ RSQGO_Hold(); return %s; }' % code
            else:
                code = '{ %s; RSQGO_Hold(); }' % code
        if nd in p.longs:
            if not code:
                code = '{ RSQGO_LongRest(); }'
            elif code.startswith('{'):
                code = '{ if (!RSQGO_LongRest()) %s }' % code[1:-1].strip()
            elif is_state:
                code = '{ if (!RSQGO_LongRest()) return %s; return null; }' % code
            else:
                code = '{ if (!RSQGO_LongRest()) %s; }' % code
        br = ' Bright' if s.get('bright') else ''
        line = ('%s %s %s%s %s' % (spr_s, fr_s, tics, br, code)).rstrip()
        return line if code.startswith('{') else line + ';'

    # ---------------------------------------------------------- per-class Default and overrides
    def class_text(self, p):
        e = p.eff
        gibp = self.by_key[p.gib] if p.gib else None
        if p.chainb:
            base = p.chainb[0].zname        # a shared base (for a flier: one that sits on its gib)
        elif gibp:
            base = gibp.zname
        else:
            base = self.runtime_parent(p)
        dl = default_lines(e, expr, gib=gibp.eff if gibp else None)
        flags = []
        allf = dict(e.flags)
        if gibp:
            for f in gibp.eff.flags:
                if f not in allf:
                    allf[f] = False
        for f in sorted(allf):
            flags.append('%s%s;' % ('+' if allf[f] else '-', f))
        dl = [x.replace('BOUNCE_FLAG_', '') for x in dl]
        if gibp:
            dl.append('RSQGO_Chunk.GibOf "%s";' % gibp.zname)
        out = ['class %s : %s' % (p.zname, base), '{', '\tDefault', '\t{']
        for x in dl + flags:
            out.append('\t\t' + x)
        out.append('\t}')
        # the flags a landing (or landing again) sets: the gib's, for every flag either side touches
        if p.become:
            gk = p.gib or p.key
            gp = self.by_key[gk]
            fs = set(e.flags) | set(gp.eff.flags) | p.chflags | gp.chflags | set(DIE_FLAGS)
            fs = {f for f in fs if f in self.fl_ok}
            body = []
            for f in sorted(fs):
                if f in BOUNCE_BITS or f in PROTECTED:
                    continue
                body.append('b%s = %s;' % (f, 'true' if gp.eff.flags.get(f, False) else 'false'))
            for f, bit in sorted(BOUNCE_BITS.items()):
                if (e.bounce | gp.eff.bounce) & bit or f in p.chflags:
                    body.append('b%s = %s;' % (f, 'true' if gp.eff.bounce & bit else 'false'))
            # NOBLOCKMAP / NOSECTOR are protected: only A_ChangeLinkFlags changes them (and it relinks the actor)
            body.append('A_ChangeLinkFlags(%d, %d);' % (bool(gp.eff.flags.get('NOBLOCKMAP')),
                                                     bool(gp.eff.flags.get('NOSECTOR'))))
            out.append('\toverride void RSQGO_ToGib()')
            out.append('\t{')
            for b in body:
                out.append('\t\t' + b)
            out.append('\t}')
        if gibp and (e.dmgf or 'damagefactor' in e.props):
            glob = expr(e.props['damagefactor'][0]) if 'damagefactor' in e.props else '1'
            out.append('\toverride double RSQGO_FlyFactor(Name dmgtype)')
            out.append('\t{')
            for _, (sp, v) in sorted(e.dmgf.items()):
                out.append("\t\tif (dmgtype == '%s') return %s * %s;" % (sp, expr(v), glob))
            out.append('\t\treturn %s;' % glob)
            out.append('\t}')
        # A flier keeps its gib's blood in its Default (it needs it once landed); where BD's flier bled differently,
        # GetBloodType (chunks.zs) asks RSQGO_FlyBlood in flight, and RSQGO_ToFlier sets its own colour at spawn
        # (RSQGO_Become copies the gib's colour back). BD's AlienHead flier bleeds red over AlienHead1's alien gib.
        if gibp:
            fb, gb = blood_of(e), blood_of(gibp.eff)
            if fb[:3] != gb[:3]:
                out.append('\toverride Name RSQGO_FlyBlood(int type)')
                out.append('\t{')
                for i in range(3):
                    out.append("\t\tif (type == %d) return '%s';" % (i, fb[i]))
                out.append("\t\treturn 'None';")
                out.append('\t}')
            if fb[3] != gb[3]:
                if fb[3]:
                    p.notes.append('its own BloodColor %s in flight is not reproduced (it bleeds its gib\'s colour)' % fb[3])
                else:
                    out.append('\toverride void RSQGO_ToFlier()')
                    out.append('\t{')
                    out.append("\t\tCopyBloodColor(GetDefaultByType('Actor'));      // BD's flier has no blood colour")
                    out.append('\t}')
        out += states_block(p.lines)
        out.append('}')
        return out

    def base_text(self, b):
        par = b.parent.zname if b.parent else b.rp
        out = ['// shared states of BD\'s %s (%d classes)' % (self.world.cls[b.key].name, len(b.members)),
               'class %s : %s' % (b.zname, par), '{']
        out += states_block(b.lines)
        out.append('}')
        return out

    # ---------------------------------------------------------- run
    def run(self):
        for p in self.plans:
            try:
                self.scan(p)
            except Unsupported as ex:
                p.left = str(ex)
        self.resolve_becoming()
        for _ in range(3):
            changed = False
            for p in self.plans:
                if p.left:
                    continue
                try:
                    self.rest_rules(p)
                    self.emit(p)
                except Unsupported as ex:
                    p.left = str(ex)
                    changed = True
            if not changed:
                break
            self.resolve_becoming()
        # a flier whose gib was left falls back to spawning it
        for p in self.plans:
            if p.gib and self.by_key[p.gib].left:
                p.gib = None
                p.become = {}
                if not p.left:
                    self.emit(p)
        self.share()
        self.render()
        return self


def states_block(lines):
    if not lines:
        return []
    out = ['\tStates', '\t{']
    for ln in lines:
        out.append(('\t' if ln.endswith(':') else '\t\t') + ln)
    out.append('\t}')
    return out


def top_calls(action):
    """The state's one call (DECORATE allows one outside { } blocks): [(name, [args])], nested calls left in the args."""
    a = action.strip()
    if not a:
        return []
    m = re.match(r'^([A-Za-z_]\w*)\s*(\()?', a)
    if not m:
        raise Unsupported('action %r' % a[:40])
    if not m.group(2):
        return [(m.group(1), [])]
    j = decorate.match_brace(a, m.end() - 1, '(', ')')
    if a[j + 1:].strip():
        raise Unsupported('action %r' % a[:40])
    return [(m.group(1), cards.split_args(a[m.end():j]))]


def props_states_text(a):
    b = getattr(a, 'body', '')
    m = re.search(r'\bstates\s*\{', b, re.I)
    return b[m.end():] if m else ''


# ------------------------------------------------------------------ MODELDEF
def read_modeldefs(packs):
    """class (lower) -> [BD's own MODELDEF blocks] (every block: GZDoom keys model frames by class + sprite + frame, so
    repeated blocks for one class add frames; BD's Guts has GUTS K -> guts1.png and GUTS L -> guts2.png). BD before
    XMVE; a later pack's blocks for a class BD already models are not added."""
    import zipfile
    out = {}
    for path, short in packs:
        mine = {}
        z = zipfile.ZipFile(path)
        for n in sorted(z.namelist()):
            base = n.replace('\\', '/').split('/')[-1]
            if '/' in n.replace('\\', '/').strip('/') or not base.lower().startswith('modeldef'):
                continue
            t = decorate.strip_comments(z.read(n).decode('latin-1'))
            for m in re.finditer(r'\bmodel\s+"?([\w]+)"?\s*\{', t, re.I):
                j = decorate.match_brace(t, m.end() - 1)
                mine.setdefault(m.group(1).lower(), []).append((m.group(1), t[m.end():j], '%s:%s' % (short, n)))
        for k, v in mine.items():
            out.setdefault(k, v)
    return out


# ------------------------------------------------------------------ writers
def write_zscript(gen, path):
    w = gen.world
    L = []
    a = L.append
    a('// RSQ Gore phase 3 classes -- GENERATED by Gore/tools/chunk_gen.py from %s and %s. Never hand-edit.' % (
        os.path.basename(gen.bd), os.path.basename(gen.xm)))
    a('//')
    a('// One class per Brutal Doom / XMVE meat, guts, limb, head, half and casing class: BD\'s own properties and states')
    a('// (the chain flattened, only what is reachable), run by the engine, with the phase 3 changes listed in the')
    a('// generator\'s docstring (trails as particles, parking instead of the corpse queue, one actor that flies and then')
    a('// becomes the landed limb, BD\'s ACS checks done natively). The runtime is chunks.zs; why each class is what it is:')
    a('// generated/chunk_summary.txt. Labels R<n>_<k> / B<n>_<k> are generated; F_ labels are a flier\'s own (see')
    a('// RSQGO_DeathEntry). RSQGO_GB_<BD base> classes hold the states a BD base class shares (never spawned, not taken')
    a('// over): the classes under it inherit them as BD\'s do, so they are compiled once.')
    a('')
    done = [p for p in gen.plans if not p.left]
    a('// ---- shared bases: states BD keeps in a base class, inherited instead of copied (chunk_gen.py Gen.share)')
    a('')
    for b in gen.bases:
        L += gen.base_text(b)
        a('')
    a('// ---- the classes')
    a('')
    # gibs first (a flier subclasses its gib), then the rest, in table order
    order = [p for p in done if any(q.gib == p.key for q in done)] + [p for p in done if not any(q.gib == p.key for q in done)]
    for p in order:
        L += gen.class_text(p)
        a('')
    a('extend class RSQGO_Gibs')
    a('{')
    a('\tconst NLIQUID = %d;' % len(gen.liquid_tokens))
    a('')
    a('\t// BD class -> our class (the takeover; RSQGO_Gibs.Lookup)')
    a('\tvoid BuildTable()')
    a('\t{')
    for p in done:
        a("\t\tAdd('%s', '%s');" % (p.name, p.zname))
    a('\t}')
    a('')
    a('\t// BD_CheckIfOverLiquid (SPLASH.acs): the floors that give each liquid token, in RSQGO_JumpIfLiquid\'s order')
    a('\tvoid BuildLiquids()')
    a('\t{')
    for i, tok in enumerate(gen.liquid_tokens):
        a('\t\tAddLiquid(%d, "%s");\t// %s' % (i, ' '.join(gen.flats[tok]), tok))
    a('\t}')
    a('}')
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')


def modeldef_blocks(gen):
    out = []
    for p in gen.plans:
        if p.left:
            continue
        srcs = [p.key]
        if p.gib:
            srcs.append(p.gib)
        for sk in srcs:
            for spelled, body, src in gen.models.get(sk, []):
                out.append((p.zname, spelled, body, src))
    return out


def write_modeldef(gen, path):
    blocks = modeldef_blocks(gen)
    L = ['// RSQ Gore phase 3 MODELDEF -- GENERATED by Gore/tools/chunk_gen.py. Never hand-edit.',
         '// BD\'s own model blocks for the phase 3 classes BD draws as models, renamed to our class: MODELDEF matches the',
         '// exact class (models.cpp FindModelFrameRaw). A flier that becomes a modelled gib also gets the gib\'s block.',
         '// Paths are BD\'s; they resolve from BD\'s pk3, which must be loaded.', '']
    for zname, spelled, body, src in blocks:
        L.append('// %s (%s)' % (spelled, src))
        L.append('Model %s' % zname)
        L.append('{')
        for ln in body.strip('\n').split('\n'):
            L.append(ln.rstrip())
        L.append('}')
        L.append('')
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')
    return len(blocks)


def write_summary(gen, path):
    done = [p for p in gen.plans if not p.left]
    left = [p for p in gen.plans if p.left]
    L = ['RSQ Gore phase 3 -- GENERATED by Gore/tools/chunk_gen.py. Never hand-edit.',
         'What each meat+guts / limb / casing class becomes (zscript/rsqgo/chunk_cards.zs, runtime chunks.zs).', '',
         '== Totals: %d classes in the table, %d transpiled (%s), %d left to BD' % (
             len(gen.plans), len(done), ', '.join('%s %d' % (c, sum(1 for p in done if p.cat == c)) for c in PHASE3),
             len(left)),
         '   fliers that become their landed limb: %d; gibs they become: %d; classes that land again in place: %d' % (
             sum(1 for p in done if p.gib), len({p.gib for p in done if p.gib}),
             sum(1 for p in done if p.become and not p.gib)),
         '   phase 1 classes they spawn (a particle call when phase 1 has a drop card for it, else by name): %s' % (
             ', '.join(sorted({c for p in done for c in p.particles}, key=lambda s: (s.lower(), s))) or 'none'),
         '   shared bases: %d (RSQGO_GB_*); state lines: %d in the bases, %d in the classes' % (
             len(gen.bases), sum(len(b.nodes) for b in gen.bases),
             sum(sum(1 for nd in p.canon['nodes'] if nd not in p.hold) for p in done)),
         '   rests that ticked forever and now park: %d frames of 1000+ tics or static loops, %d long loop states, '
         '%d 1000+ tic states that hold after their action' % (
             sum(len(p.forever) for p in done), sum(len(p.longs) for p in done), sum(len(p.holds) for p in done)),
         '']
    L.append('== Classes')
    for p in gen.plans:
        if p.left:
            continue
        bits = [p.cat]
        if p.gib:
            bits.append('FLIES, THEN BECOMES %s' % gen.by_key[p.gib].name)
        if p.become and not p.gib:
            bits.append('lands again in place')
        if p.shootable:
            bits.append('shootable')
        if p.forever or p.longs or p.holds:
            bits.append('parks (%d forever frames, %d long loops, %d holds)' % (len(p.forever), len(p.longs), len(p.holds)))
        if p.particles:
            bits.append('particles: ' + ', '.join(sorted(p.particles, key=lambda s: (s.lower(), s))))
        bits.append('%d states' % len(p.g.nodes))
        L.append('  %-40s -> %s; %s' % (p.name, p.zname, '; '.join(bits)))
    L.append('')
    L.append('== Left to BD: %d (they stay BD\'s actors; what they spawn is still taken over)' % len(left))
    for p in left:
        L.append('  %-40s %s' % (p.name, p.left))
    L.append('')
    L.append('== Notes (dropped flags and properties, fallbacks)')
    for p in gen.plans:
        notes = sorted(set(p.notes))
        if p.eff:
            for nm in sorted(p.eff.props):
                if nm not in NUM_PROPS + STR_PROPS + LIST_PROPS + ('damage', 'painchance', 'damagefactor', 'bouncetype'):
                    notes.append('property %s dropped' % nm)
        for n in notes:
            L.append('  %s: %s' % (p.name, n))
    L.append('')
    L.append('== MODELDEF blocks copied: %s' % (', '.join('%s (%s)' % (z, s) for z, s, _, _ in modeldef_blocks(gen)) or 'none'))
    L.append('== Liquid tokens (BD SPLASH.acs): %s' % ('; '.join('%d %s: %s' % (i, t, ' '.join(gen.flats[t]))
                                                        for i, t in enumerate(gen.liquid_tokens)) or 'NOT FOUND'))
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')
    return L


def write_all(bd, xm, root=GORE):
    gen = Gen(bd, xm).run()
    P = {k: os.path.join(root, v) for k, v in OUT.items()}
    for p in P.values():
        os.makedirs(os.path.dirname(p) or '.', exist_ok=True)
    write_zscript(gen, P['zscript'])
    nm = write_modeldef(gen, P['modeldef'])
    lines = write_summary(gen, P['summary'])
    return gen, P, nm, lines


def main(argv):
    if len(argv) != 3:
        print(__doc__.strip().split('\n\n')[1])
        return 2
    for p in argv[1:]:
        if not os.path.isfile(p):
            print('chunk_gen: no such pk3: ' + p)
            return 2
    gen, P, nm, lines = write_all(argv[1], argv[2])
    done = sum(1 for p in gen.plans if not p.left)
    print('wrote %s (%d classes, %d left to BD)' % (P['zscript'], done, len(gen.plans) - done))
    print('wrote %s (%d model blocks)' % (P['modeldef'], nm))
    print('wrote %s' % P['summary'])
    print('\n'.join(lines[3:9]))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
