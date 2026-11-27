"""hitsensor_dec.py -- the DECORATE reader shared by hitsensor_gen.py and hitsensor_lint.py.

Reads Brutal Doom 22's DECORATE (the unpacked source folder) and XMVE's pk3 (read-only, zipfile) and returns every
actor's own properties, flags, parent and Spawn-state length. Only what the hit sensors need: it is not a general
DECORATE parser, and it never writes anything.
"""
import os
import re
import zipfile

BD_SRC = r"C:\Users\Command\AppData\Local\Temp\claude\8fba6c6ba7d4835b\4f849543-9da9-4c10-95eb-c7cb79475573\scratchpad\bd22\src"
XMVE_PK3 = r"D:\SteamLibrary\steamapps\Common\DooM VR\__CurrentRotationDONOTDELETE\1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3"

HEAD_ROOT = "headshottargetbase"
LEG_ROOT = "legtargetbase"
# the per-frame helpers are the classes NAMED as helpers (design section 9: `is HeadshotTargetBase` alone also takes
# MeatShield, TankEngineWeakSpot, FuelTankPhysics, RiotShieldPhysics and four boss hitboxes, which are not helpers)
HELPER_NAME = re.compile(r"^(headshottarget|legtarget)", re.I)


def strip_comments(t):
    t = re.sub(r"/\*.*?\*/", "", t, flags=re.S)
    return re.sub(r"//[^\n]*", "", t)


ACTOR_HEAD = re.compile(r"(?im)^[ \t]*actor[ \t]+([\w.]+)[ \t]*(?::[ \t]*([\w.]+))?[^{\n]*\s*\{")


class Actor:
    def __init__(self, name, parent, origin, body):
        self.name = name
        self.key = name.lower()
        self.parent = parent.lower() if parent else None
        self.origin = origin
        self.body = body
        self.props = {}          # lower-case property -> raw value string
        self.factors = {}        # damage type (lower) -> float
        self.flags = {}          # flag (upper) -> True / False
        self.spawn_tics = None   # own Spawn state's length (sum of tics to Stop), None if it has no Spawn
        self.spawn_loops = False
        self.states = ""
        self._parse()

    def _parse(self):
        b = self.body
        m = re.search(r"(?is)\bstates\s*\{", b)
        head = b[:m.start()] if m else b
        if m:
            self.states = b[m.end():]
        for f in re.finditer(r"(?i)damagefactor\s+\"?([\w]+)\"?\s*,\s*([-\d.]+)", head):
            self.factors[f.group(1).lower()] = float(f.group(2))
        head2 = re.sub(r"(?i)damagefactor\s+\"?[\w]+\"?\s*,\s*[-\d.]+", " ", head)
        for f in re.finditer(r"(?<![\w\"])([+-])([A-Za-z_][\w.]*)", head2):
            self.flags[f.group(2).upper()] = f.group(1) == "+"
        for line in head2.splitlines():
            line = re.sub(r"(?<![\w\"])[+-][A-Za-z_][\w.]*", " ", line).strip()
            mm = re.match(r"([A-Za-z_][\w.]*)\s+(.+)$", line)
            if mm:
                self.props[mm.group(1).lower()] = mm.group(2).strip()
        if self.states:
            self.spawn_tics, self.spawn_loops = spawn_length(self.states)


FRAME = re.compile(r"^\s*(\"?[\w#-]{4}\"?)\s+(\"?[\w\[\]\\#]+\"?)\s+(-?\d+)\b")


def spawn_length(states):
    """Sum of the Spawn state's tics, followed to Stop (fall-through labels included); a Loop / Goto / -1 ends it."""
    lines = states.splitlines()
    i = 0
    while i < len(lines) and not re.match(r"(?i)^\s*spawn\s*:", lines[i]):
        i += 1
    if i == len(lines):
        return None, False
    total = 0
    for line in lines[i + 1:]:
        s = line.strip()
        if not s:
            continue
        if re.match(r"(?i)^(stop)\b", s):
            return total, False
        if re.match(r"(?i)^(loop|wait|goto|fail)\b", s):
            return total, True
        if re.match(r"^[\w.]+\s*:\s*$", s):
            continue                          # a label: Spawn falls through it
        m = FRAME.match(line)
        if m:
            t = int(m.group(3))
            if t < 0:
                return total, True
            frames = m.group(2).strip('"')
            total += t * max(1, len(frames))
    return total, False


def read_sources(bd_src=BD_SRC, xmve_pk3=XMVE_PK3):
    """{class key: Actor}. XMVE is read after BD, so a class XMVE redefines takes XMVE's definition (as in the game)."""
    actors = {}

    def take(text, origin):
        t = strip_comments(text)
        for m in ACTOR_HEAD.finditer(t):
            depth, j = 1, m.end()
            while j < len(t) and depth:
                if t[j] == "{":
                    depth += 1
                elif t[j] == "}":
                    depth -= 1
                j += 1
            a = Actor(m.group(1), m.group(2), origin, t[m.end():j - 1])
            actors[a.key] = a

    for root, _, files in os.walk(os.path.join(bd_src, "actors")):
        for f in sorted(files):
            p = os.path.join(root, f)
            with open(p, "rb") as fh:
                take(fh.read().decode("latin-1"), "BD:" + os.path.relpath(p, bd_src).replace("\\", "/"))
    with zipfile.ZipFile(xmve_pk3) as z:
        for n in sorted(z.namelist()):
            if n.endswith("/") or not re.search(r"(?i)(\.txt|\.dec|decorate[^/]*)$", n):
                continue
            take(z.read(n).decode("latin-1"), "XMVE:" + n)
    return actors


def chain(actors, key):
    out = []
    while key and key in actors and key not in out:
        out.append(key)
        key = actors[key].parent
    return out


def resolved(actors, key):
    """The class's effective properties, factors, flags and Spawn length (own first, then its parents')."""
    props, factors, flags, life, loops = {}, {}, {}, None, False
    for k in reversed(chain(actors, key)):
        a = actors[k]
        props.update(a.props)
        factors.update(a.factors)
        flags.update(a.flags)
        if a.spawn_tics is not None:
            life, loops = a.spawn_tics, a.spawn_loops
    return props, factors, flags, life, loops


def helpers(actors):
    """(head helpers, leg helpers, `is` subclasses that are not helpers): class keys, sorted."""
    head, leg, other = [], [], []
    for k in sorted(actors):
        c = chain(actors, k)
        root = HEAD_ROOT if HEAD_ROOT in c else (LEG_ROOT if LEG_ROOT in c else None)
        if not root:
            continue
        if not HELPER_NAME.match(k):
            other.append(k)
        elif root == HEAD_ROOT:
            head.append(k)
        else:
            leg.append(k)
    return head, leg, other


def spawned_helper_names(xmve_pk3=XMVE_PK3):
    """{lower class name: call count} for every helper XMVE spawns by name (A_SpawnItem / A_SpawnItemEx / ...)."""
    out = {}
    pat = re.compile(r"(?i)A_\w+\s*\(\s*\"((?:headshottarget|legtarget)\w*)\"")
    with zipfile.ZipFile(xmve_pk3) as z:
        for n in z.namelist():
            if n.endswith("/"):
                continue
            t = strip_comments(z.read(n).decode("latin-1"))
            for m in pat.finditer(t):
                out[m.group(1).lower()] = out.get(m.group(1).lower(), 0) + 1
    return out
