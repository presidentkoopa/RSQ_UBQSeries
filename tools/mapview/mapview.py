#!/usr/bin/env python3
"""mapview.py: top-down Doom map viewer with room rectangles you draw yourself.

Reads a WAD (or a PK3/ZIP holding maps/*.wad) and writes one self-contained HTML
page per map, plus index.html. Standard library only (Python 3.8+).

    python3 mapview.py DOOM2.WAD -o mapview_out
    python3 mapview.py DOOM2.WAD MapsOfChaos.wad -o mapview_out --maps MAP01,MAP07

Map formats: Doom (vanilla/Boom), Hexen (ZDoom-in-Hexen) and UDMF (TEXTMAP).
See README.md next to this file.
"""
import argparse
import colorsys
import html
import json
import math
import os
import re
import struct
import sys
import zipfile

# ---------------------------------------------------------------- WAD reading

MAP_LUMPS = {"THINGS", "LINEDEFS", "SIDEDEFS", "VERTEXES", "SEGS", "SSECTORS",
             "NODES", "SECTORS", "REJECT", "BLOCKMAP", "BEHAVIOR", "SCRIPTS"}


def read_wad(data):
    ident, n, off = struct.unpack_from("<4sii", data, 0)
    if ident not in (b"IWAD", b"PWAD"):
        raise ValueError("not a WAD file")
    lumps = []
    for i in range(n):
        pos, size, name = struct.unpack_from("<ii8s", data, off + i * 16)
        name = name.split(b"\0")[0].decode("latin-1").upper()
        lumps.append((name, data[pos:pos + size]))
    return lumps


def find_maps(lumps):
    """Yield (mapname, {lumpname: bytes}) for every map in a lump list."""
    out = []
    i = 0
    while i < len(lumps):
        name = lumps[i][0]
        nxt = lumps[i + 1][0] if i + 1 < len(lumps) else ""
        if nxt == "TEXTMAP":
            d = {}
            j = i + 1
            while j < len(lumps) and lumps[j][0] != "ENDMAP":
                d[lumps[j][0]] = lumps[j][1]
                j += 1
            out.append((name, d))
            i = j + 1
            continue
        if nxt == "THINGS":
            d = {}
            j = i + 1
            while j < len(lumps) and lumps[j][0] in MAP_LUMPS:
                d[lumps[j][0]] = lumps[j][1]
                j += 1
            out.append((name, d))
            i = j
            continue
        i += 1
    return out


def load_source(path):
    """Return list of (mapname, lumps) from a WAD, or from a PK3/ZIP (maps/*.wad)."""
    with open(path, "rb") as f:
        data = f.read()
    if data[:4] in (b"IWAD", b"PWAD"):
        return find_maps(read_wad(data))
    if data[:2] == b"PK":
        maps = []
        with zipfile.ZipFile(path) as z:
            for info in z.infolist():
                low = info.filename.lower()
                if low.endswith(".wad"):
                    try:
                        sub = find_maps(read_wad(z.read(info)))
                    except ValueError:
                        continue
                    if low.startswith("maps/") and len(sub) == 1:
                        stem = os.path.splitext(os.path.basename(info.filename))[0].upper()
                        sub = [(stem, sub[0][1])]
                    maps.extend(sub)
        return maps
    raise ValueError("%s: not a WAD or PK3" % path)


# ---------------------------------------------------------------- map parsing

class Map:
    def __init__(self):
        self.verts = []    # (x, y)
        self.lines = []    # dict v1 v2 flags special args tag front back blocksound twosided trig
        self.sides = []    # sector index
        self.sectors = []  # dict floor ceil light special tag secret
        self.things = []   # dict x y type angle skills(set of 1..5) mp_only
        self.fmt = "doom"


def parse_doom(lumps, hexen):
    m = Map()
    m.fmt = "hexen" if hexen else "doom"
    v = lumps.get("VERTEXES", b"")
    m.verts = [struct.unpack_from("<hh", v, i) for i in range(0, len(v) - 3, 4)]
    s = lumps.get("SECTORS", b"")
    for i in range(0, len(s) - 25, 26):
        fh, ch, _ft, _ct, light, special, tag = struct.unpack_from("<hh8s8shhh", s, i)
        if hexen:
            secret = bool(special & 1024)
        else:
            secret = special == 9 or bool(special & 128 and special >= 32)
        m.sectors.append(dict(floor=fh, ceil=ch, light=light, special=special,
                              tag=tag, secret=secret))
    sd = lumps.get("SIDEDEFS", b"")
    m.sides = [struct.unpack_from("<h", sd, i + 28)[0] for i in range(0, len(sd) - 29, 30)]
    ld = lumps.get("LINEDEFS", b"")
    if hexen:
        for i in range(0, len(ld) - 15, 16):
            v1, v2, flags, sp, a0, a1, a2, a3, a4, fr, bk = struct.unpack_from("<HHHB5BHH", ld, i)
            spac = (flags >> 10) & 7
            trig = {0: "W", 1: "S", 2: "M", 3: "G", 4: "P", 5: "W"}.get(spac, "?")
            trig += "R" if flags & 0x200 else "1"
            m.lines.append(dict(v1=v1, v2=v2, flags=flags, special=sp,
                                args=[a0, a1, a2, a3, a4], tag=a0, front=fr, back=bk,
                                blocksound=bool(flags & 0x40), trig=trig))
    else:
        for i in range(0, len(ld) - 13, 14):
            v1, v2, flags, sp, tag, fr, bk = struct.unpack_from("<HHHHHHH", ld, i)
            m.lines.append(dict(v1=v1, v2=v2, flags=flags, special=sp, args=None,
                                tag=tag, front=fr, back=bk,
                                blocksound=bool(flags & 0x40), trig=None))
    t = lumps.get("THINGS", b"")
    if hexen:
        for i in range(0, len(t) - 19, 20):
            _tid, x, y, _z, ang, typ, fl = struct.unpack_from("<hhhhhhh", t, i)
            m.things.append(dict(x=x, y=y, type=typ, angle=ang,
                                 skills=skills_from_bits(fl),
                                 mp_only=not (fl & 0x100)))
    else:
        for i in range(0, len(t) - 9, 10):
            x, y, ang, typ, fl = struct.unpack_from("<hhhhh", t, i)
            m.things.append(dict(x=x, y=y, type=typ, angle=ang,
                                 skills=skills_from_bits(fl),
                                 mp_only=bool(fl & 16)))
    return m


def skills_from_bits(fl):
    s = set()
    if fl & 1:
        s |= {1, 2}
    if fl & 2:
        s |= {3}
    if fl & 4:
        s |= {4, 5}
    return s


def parse_udmf(text):
    m = Map()
    m.fmt = "udmf"
    text = re.sub(r"//[^\n]*|/\*.*?\*/", "", text, flags=re.S)
    blocks = re.finditer(r"(\w+)\s*\{([^}]*)\}", text)
    kv = re.compile(r"(\w+)\s*=\s*(\"(?:[^\"\\]|\\.)*\"|[^;]+);")

    def val(x):
        x = x.strip()
        if x.startswith('"'):
            return x[1:-1]
        lx = x.lower()
        if lx == "true":
            return True
        if lx == "false":
            return False
        try:
            return int(x, 0)
        except ValueError:
            try:
                return float(x)
            except ValueError:
                return x
    raw = {"vertex": [], "linedef": [], "sidedef": [], "sector": [], "thing": []}
    for b in blocks:
        kind = b.group(1).lower()
        if kind in raw:
            raw[kind].append({k.lower(): val(v) for k, v in kv.findall(b.group(2))})
    m.verts = [(float(d.get("x", 0)), float(d.get("y", 0))) for d in raw["vertex"]]
    for d in raw["sector"]:
        sp = int(d.get("special", 0))
        m.sectors.append(dict(floor=d.get("heightfloor", 0), ceil=d.get("heightceiling", 0),
                              light=d.get("lightlevel", 160), special=sp,
                              tag=int(d.get("id", 0)),
                              secret=bool(d.get("secret", False)) or bool(sp & 1024) or sp == 195))
    m.sides = [int(d.get("sector", 0)) for d in raw["sidedef"]]
    for d in raw["linedef"]:
        args = [int(d.get("arg%d" % k, 0)) for k in range(5)]
        if d.get("playeruse") or d.get("playerpush"):
            trig = "S"
        elif d.get("impact"):
            trig = "G"
        elif d.get("playercross") or d.get("monstercross"):
            trig = "W"
        else:
            trig = "?"
        trig += "R" if d.get("repeatspecial") else "1"
        bk = int(d.get("sideback", -1))
        m.lines.append(dict(v1=int(d["v1"]), v2=int(d["v2"]), flags=0,
                            special=int(d.get("special", 0)), args=args, tag=args[0],
                            front=int(d.get("sidefront", -1)),
                            back=0xFFFF if bk < 0 else bk,
                            blocksound=bool(d.get("blocksound", False)), trig=trig))
    for d in raw["thing"]:
        sk = {k for k in range(1, 6) if d.get("skill%d" % k)}
        single = d.get("single", None)
        m.things.append(dict(x=float(d.get("x", 0)), y=float(d.get("y", 0)),
                             type=int(d.get("type", 0)), angle=int(d.get("angle", 0)),
                             skills=sk, mp_only=(single is False) or
                             (single is None and (d.get("coop") or d.get("dm")))))
    return m


def parse_map(lumps):
    if "TEXTMAP" in lumps:
        return parse_udmf(lumps["TEXTMAP"].decode("latin-1"))
    return parse_doom(lumps, "BEHAVIOR" in lumps)


# ---------------------------------------------------------------- specials

# Vanilla Doom line specials: number -> (trigger, kind, short text)
# kinds: door lift floor ceiling stairs crusher donut light exit teleport other
_D = """
1 DR door Door open-wait-close|2 W1 door Door open|3 W1 door Door close|4 W1 door Door open-wait-close
5 W1 floor Floor up to lowest ceiling|6 W1 crusher Fast crusher|7 S1 stairs Stairs +8|8 W1 stairs Stairs +8
9 S1 donut Donut|10 W1 lift Lift|11 S1 exit Exit|12 W1 light Light max neighbour|13 W1 light Light 255
14 S1 floor Floor up 32|15 S1 floor Floor up 24|16 W1 door Door close 30s open|17 W1 light Light blink
18 S1 floor Floor up next|19 W1 floor Floor down highest|20 S1 floor Floor up next|21 S1 lift Lift
22 W1 floor Floor up next|23 S1 floor Floor down lowest|24 G1 floor Floor up lowest ceiling
25 W1 crusher Crusher|26 DR door Blue door|27 DR door Yellow door|28 DR door Red door
29 S1 door Door open-wait-close|30 W1 floor Floor up shortest tex|31 D1 door Door open|32 D1 door Blue door open
33 D1 door Red door open|34 D1 door Yellow door open|35 W1 light Light 35|36 W1 floor Floor down fast
37 W1 floor Floor down lowest|38 W1 floor Floor down lowest|39 W1 teleport Teleport|40 W1 ceiling Ceiling up highest
41 S1 ceiling Ceiling down floor|42 SR door Door close|43 SR ceiling Ceiling down floor|44 W1 ceiling Ceiling down floor+8
45 SR floor Floor down highest|46 GR door Door open|47 G1 floor Floor up next|49 S1 crusher Crusher
50 S1 door Door close|51 S1 exit Secret exit|52 W1 exit Exit|53 W1 floor Perpetual platform
54 W1 floor Platform stop|55 S1 floor Floor up crush|56 W1 floor Floor up crush|57 W1 crusher Crusher stop
58 W1 floor Floor up 24|59 W1 floor Floor up 24|60 SR floor Floor down lowest|61 SR door Door open
62 SR lift Lift|63 SR door Door open-wait-close|64 SR floor Floor up lowest ceiling|65 SR floor Floor up crush
66 SR floor Floor up 24|67 SR floor Floor up 32|68 SR floor Floor up next|69 SR floor Floor up next
70 SR floor Floor down fast|71 S1 floor Floor down fast|72 WR ceiling Ceiling down floor+8|73 WR crusher Crusher
74 WR crusher Crusher stop|75 WR door Door close|76 WR door Door close 30s open|77 WR crusher Fast crusher
79 WR light Light 35|80 WR light Light max neighbour|81 WR light Light 255|82 WR floor Floor down lowest
83 WR floor Floor down highest|84 WR floor Floor down lowest|86 WR door Door open|87 WR floor Perpetual platform
88 WR lift Lift|89 WR floor Platform stop|90 WR door Door open-wait-close|91 WR floor Floor up lowest ceiling
92 WR floor Floor up 24|93 WR floor Floor up 24|94 WR floor Floor up crush|95 WR floor Floor up next
96 WR floor Floor up shortest tex|97 WR teleport Teleport|98 WR floor Floor down fast|99 SR door Blue door open fast
100 W1 stairs Turbo stairs|101 S1 floor Floor up lowest ceiling|102 S1 floor Floor down highest|103 S1 door Door open
104 W1 light Light min neighbour|105 WR door Fast door|106 WR door Fast door open|107 WR door Fast door close
108 W1 door Fast door|109 W1 door Fast door open|110 W1 door Fast door close|111 S1 door Fast door
112 S1 door Fast door open|113 S1 door Fast door close|114 SR door Fast door|115 SR door Fast door open
116 SR door Fast door close|117 DR door Fast door|118 D1 door Fast door open|119 W1 floor Floor up next
120 WR lift Fast lift|121 W1 lift Fast lift|122 S1 lift Fast lift|123 SR lift Fast lift|124 W1 exit Secret exit
125 W1 teleport Monster teleport|126 WR teleport Monster teleport|127 S1 stairs Turbo stairs|128 WR floor Floor up next
129 WR floor Floor up next fast|130 W1 floor Floor up next fast|131 S1 floor Floor up next fast
132 SR floor Floor up next fast|133 S1 door Blue door fast|134 SR door Red door fast|135 S1 door Red door fast
136 SR door Yellow door fast|137 S1 door Yellow door fast|138 SR light Light 255|139 SR light Light 35
140 S1 floor Floor up 512|141 W1 crusher Silent crusher
142 W1 floor Floor up 512|143 W1 floor Raise 24|144 W1 floor Raise 32|145 W1 ceiling Ceiling down floor
146 W1 donut Donut|147 WR floor Floor up 512|148 WR floor Raise 24|149 WR floor Raise 32|150 WR crusher Silent crusher
151 WR ceiling Ceiling up highest|152 WR ceiling Ceiling down floor|153 W1 floor Change texture|154 WR floor Change texture
155 WR donut Donut|156 WR light Light blink|157 WR light Light min neighbour|158 S1 floor Floor up shortest tex
159 S1 floor Floor down lowest|160 S1 floor Floor up 24|161 S1 floor Floor up 24|162 S1 floor Perpetual platform
163 S1 floor Platform stop|164 S1 crusher Fast crusher|165 S1 crusher Silent crusher|166 S1 ceiling Ceiling up highest
167 S1 ceiling Ceiling down floor+8|168 S1 crusher Crusher stop|169 S1 light Light max|170 S1 light Light 35
171 S1 light Light 255|172 S1 light Light blink|173 S1 light Light min|174 S1 teleport Teleport
175 S1 door Door close 30s open|176 SR floor Floor up shortest tex|177 SR floor Floor down lowest
178 SR floor Floor up 512|179 SR floor Raise 24|180 SR floor Raise 32|181 SR floor Perpetual platform
182 SR floor Platform stop|183 SR crusher Fast crusher|184 SR crusher Crusher|185 SR crusher Silent crusher
186 SR ceiling Ceiling up highest|187 SR ceiling Ceiling down floor+8|188 SR crusher Crusher stop
189 S1 floor Change texture|190 SR floor Change texture|191 SR donut Donut|192 SR light Light max
193 SR light Light blink|194 SR light Light min|195 SR teleport Teleport|196 SR door Door close 30s open
197 G1 exit Exit|198 G1 exit Secret exit|199 W1 ceiling Ceiling down lowest|200 W1 ceiling Ceiling down highest
201 WR ceiling Ceiling down lowest|202 WR ceiling Ceiling down highest|203 S1 ceiling Ceiling down lowest
204 S1 ceiling Ceiling down highest|205 SR ceiling Ceiling down lowest|206 SR ceiling Ceiling down highest
207 W1 teleport Silent teleport|208 WR teleport Silent teleport|209 S1 teleport Silent teleport|210 SR teleport Silent teleport
211 SR floor Toggle floor|212 WR floor Toggle floor|219 W1 floor Floor down next|220 WR floor Floor down next
221 S1 floor Floor down next|222 SR floor Floor down next|227 W1 lift Elevator up|228 WR lift Elevator up
229 S1 lift Elevator up|230 SR lift Elevator up|231 W1 lift Elevator down|232 WR lift Elevator down
233 S1 lift Elevator down|234 SR lift Elevator down|235 W1 lift Elevator here|236 WR lift Elevator here
237 S1 lift Elevator here|238 SR lift Elevator here|239 W1 floor Change texture|240 WR floor Change texture
241 S1 floor Change texture|243 W1 teleport Line teleport|244 WR teleport Line teleport
262 W1 teleport Line teleport|263 WR teleport Line teleport|264 W1 teleport Line teleport|265 WR teleport Line teleport
266 W1 teleport Line teleport|267 WR teleport Line teleport|268 W1 teleport Silent teleport|269 WR teleport Silent teleport
"""
DOOM_SPECIALS = {}
for _item in _D.replace("\n", "|").split("|"):
    _item = _item.strip()
    if _item:
        _n, _t, _k, _txt = _item.split(" ", 3)
        DOOM_SPECIALS[int(_n)] = (_t, _k, _txt)

GEN_TRIG = ["W1", "WR", "S1", "SR", "G1", "GR", "D1", "DR"]


def doom_special(sp):
    if sp in DOOM_SPECIALS:
        return DOOM_SPECIALS[sp]
    if sp >= 0x2F80:  # Boom generalized
        trig = GEN_TRIG[sp & 7]
        for base, kind, txt in ((0x6000, "floor", "Gen floor"), (0x4000, "ceiling", "Gen ceiling"),
                                (0x3C00, "door", "Gen door"), (0x3800, "door", "Gen locked door"),
                                (0x3400, "lift", "Gen lift"), (0x3000, "stairs", "Gen stairs"),
                                (0x2F80, "crusher", "Gen crusher")):
            if sp >= base:
                return (trig, kind, txt)
    return None


_HX = {}
for _nums, _kind, _txt in (
        ((10, 11, 12, 13, 14, 202, 249), "door", "Door"),
        ((60, 62, 63, 64, 65, 172, 203, 206, 207, 228, 230, 231, 245, 246, 247), "lift", "Platform"),
        ((20, 21, 22, 23, 24, 25, 26, 27, 28, 35, 36, 37, 66, 67, 68, 95, 96, 200, 201, 238, 239, 240,
          241, 242, 250, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268), "floor", "Floor"),
        ((40, 41, 42, 43, 44, 45, 69, 192, 193, 194, 195, 196, 197, 198, 199, 251, 252, 253, 254, 255),
         "ceiling", "Ceiling"),
        ((8, 26, 27, 28, 29, 30, 31, 204, 217), "stairs", "Stairs"),
        ((97, 99, 104, 105, 168, 169, 195, 196), "crusher", "Crusher"),
        ((70, 71, 76, 77, 215), "teleport", "Teleport"),
        ((74, 243, 244), "exit", "Exit")):
    for _n in _nums:
        _HX.setdefault(_n, (_kind, _txt))
_HX[26] = ("stairs", "Stairs")
_HX[27] = ("stairs", "Stairs")
_HX[28] = ("stairs", "Stairs")


def line_action(m, ln):
    """(trigger, kind, text) or None."""
    sp = ln["special"]
    if not sp:
        return None
    if m.fmt == "doom":
        return doom_special(sp)
    kind, txt = _HX.get(sp, ("other", "Special"))
    trig = ln["trig"] or "?"
    # manual (tag 0 on a door/plat) acts on the back sector: show it as D
    if kind in ("door", "lift") and ln["tag"] == 0 and trig[0] == "S":
        trig = "D" + trig[1]
    return (trig, kind, "%s (%d)" % (txt, sp))


# ---------------------------------------------------------------- things

MONSTERS = {  # ednum: (name, tier 1..4)
    3004: ("Zombieman", 1), 9: ("Shotgun guy", 1), 65: ("Chaingunner", 2), 3001: ("Imp", 1),
    3002: ("Demon", 1), 58: ("Spectre", 1), 3006: ("Lost soul", 1), 3005: ("Cacodemon", 2),
    69: ("Hell knight", 2), 3003: ("Baron", 3), 68: ("Arachnotron", 2), 71: ("Pain elemental", 3),
    66: ("Revenant", 2), 67: ("Mancubus", 3), 64: ("Arch-vile", 3), 16: ("Cyberdemon", 4),
    7: ("Spider Mastermind", 4), 84: ("SS", 1), 72: ("Commander Keen", 1), 88: ("Boss brain", 4),
    89: ("Boss shooter", 4),
}
KEYS = {5: ("Blue keycard", "#1f5bff"), 40: ("Blue skull", "#1f5bff"),
        6: ("Yellow keycard", "#e8c300"), 39: ("Yellow skull", "#e8c300"),
        13: ("Red keycard", "#e01010"), 38: ("Red skull", "#e01010")}
STARTS = {1: "Player 1", 2: "Player 2", 3: "Player 3", 4: "Player 4"}
TIER_COLOR = {1: "#d0201a", 2: "#a00090", 3: "#5a00c8", 4: "#000000"}


# ---------------------------------------------------------------- geometry

def sector_loops(m):
    """Per sector, a list of closed vertex loops (indices)."""
    edges = [[] for _ in m.sectors]
    ns = len(m.sides)
    for ln in m.lines:
        fs = m.sides[ln["front"]] if ln["front"] < ns else -1
        bs = m.sides[ln["back"]] if ln["back"] < ns else -1
        if fs == bs:
            continue
        if 0 <= fs < len(m.sectors):
            edges[fs].append((ln["v1"], ln["v2"]))
        if 0 <= bs < len(m.sectors):
            edges[bs].append((ln["v2"], ln["v1"]))
    loops = []
    for el in edges:
        out = {}
        for e in el:
            out.setdefault(e[0], []).append(e)
        used = set()
        sl = []
        for e in el:
            if e in used:
                continue
            loop = [e[0]]
            cur = e
            used.add(cur)
            start = e[0]
            while True:
                loop.append(cur[1])
                if cur[1] == start:
                    break
                cands = [c for c in out.get(cur[1], ()) if c not in used]
                if not cands:
                    break
                cur = cands[0]
                used.add(cur)
            if len(loop) >= 3:
                sl.append(loop)
        loops.append(sl)
    return loops


def point_in_loops(x, y, pts_loops):
    inside = False
    for pts in pts_loops:
        n = len(pts)
        for i in range(n - 1):
            x1, y1 = pts[i]
            x2, y2 = pts[i + 1]
            if (y1 > y) != (y2 > y):
                xi = x1 + (y - y1) * (x2 - x1) / (y2 - y1)
                if xi > x:
                    inside = not inside
    return inside


def loops_area(pts_loops):
    a = 0.0
    for pts in pts_loops:
        s = 0.0
        for i in range(len(pts) - 1):
            s += pts[i][0] * pts[i + 1][1] - pts[i + 1][0] * pts[i][1]
        a += abs(s) / 2
    return a


def label_point(pts_loops):
    """An interior point far from the edges (sampled)."""
    xs = [p[0] for l in pts_loops for p in l]
    ys = [p[1] for l in pts_loops for p in l]
    if not xs:
        return None
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    segs = [(l[i], l[i + 1]) for l in pts_loops for i in range(len(l) - 1)]
    best, bd = None, -1
    N = 14
    for i in range(N):
        for j in range(N):
            px = x0 + (x1 - x0) * (i + 0.5) / N
            py = y0 + (y1 - y0) * (j + 0.5) / N
            if not point_in_loops(px, py, pts_loops):
                continue
            d = min(seg_dist(px, py, a, b) for a, b in segs)
            if d > bd:
                bd, best = d, (px, py)
    if best is None:
        best = ((x0 + x1) / 2, (y0 + y1) / 2)
    return best


def seg_dist(px, py, a, b):
    ax, ay = a
    bx, by = b
    dx, dy = bx - ax, by - ay
    L = dx * dx + dy * dy
    t = 0 if L == 0 else max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / L))
    qx, qy = ax + t * dx - px, ay + t * dy - py
    return math.hypot(qx, qy)


# ---------------------------------------------------------------- analysis

def analyse(m):
    ns, nsec = len(m.sides), len(m.sectors)

    def sec(side):
        if side < ns:
            s = m.sides[side]
            if 0 <= s < nsec:
                return s
        return -1
    for ln in m.lines:
        ln["fs"] = sec(ln["front"])
        ln["bs"] = sec(ln["back"])
        ln["act"] = line_action(m, ln)
    tagmap = {}
    for i, s in enumerate(m.sectors):
        if s["tag"]:
            tagmap.setdefault(s["tag"], []).append(i)
    door_secs, lift_secs = set(), set()
    for ln in m.lines:
        a = ln["act"]
        if not a or a[1] not in ("door", "lift"):
            continue
        target = door_secs if a[1] == "door" else lift_secs
        if a[0][0] == "D" or (m.fmt != "doom" and ln["tag"] == 0):
            if ln["bs"] >= 0:
                target.add(ln["bs"])
        else:
            target.update(tagmap.get(ln["tag"], ()))
    # areas: flood fill across two-sided lines, stop at door/lift sectors and sound blockers
    stop = door_secs | lift_secs
    adj = [[] for _ in range(nsec)]
    for ln in m.lines:
        a, b = ln["fs"], ln["bs"]
        if a < 0 or b < 0 or a == b or ln["blocksound"]:
            continue
        adj[a].append(b)
        adj[b].append(a)
    area = [-1] * nsec
    areas = []
    for s0 in range(nsec):
        if area[s0] >= 0 or s0 in stop:
            continue
        aid = len(areas)
        stack, members = [s0], []
        area[s0] = aid
        while stack:
            s = stack.pop()
            members.append(s)
            for t in adj[s]:
                if area[t] < 0 and t not in stop:
                    area[t] = aid
                    stack.append(t)
        areas.append(members)
    return dict(door_secs=door_secs, lift_secs=lift_secs, area=area, areas=areas, tagmap=tagmap)


# ---------------------------------------------------------------- HTML

def fmt(v):
    if isinstance(v, float) and not v.is_integer():
        return "%.1f" % v
    return "%d" % v


def area_color(i):
    h = (i * 0.61803398875) % 1.0
    r, g, b = colorsys.hls_to_rgb(h, 0.55, 0.85)
    return "#%02x%02x%02x" % (int(r * 255), int(g * 255), int(b * 255))


def build_html(wadname, mapname, m, template):
    info = analyse(m)
    V = m.verts
    loops = sector_loops(m)
    if not V:
        return None
    xs = [v[0] for v in V]
    ys = [v[1] for v in V]
    minx, maxx, miny, maxy = min(xs), max(xs), min(ys), max(ys)
    floors = [s["floor"] for s in m.sectors] or [0]
    fmin, fmax = min(floors), max(floors)

    def P(i):
        return "%s %s" % (fmt(V[i][0]), fmt(-V[i][1]))

    # number areas by floor size, biggest first
    sa = [loops_area([[V[k] for k in l] for l in sl]) for sl in loops]
    sizes = [sum(sa[s] for s in mem if s < len(sa)) for mem in info["areas"]]
    order = sorted(range(len(sizes)), key=lambda a: -sizes[a])
    remap = {old: new for new, old in enumerate(order)}
    info["areas"] = [info["areas"][a] for a in order]
    info["area_size"] = [sizes[a] for a in order]
    info["area"] = [remap[a] if a >= 0 else -1 for a in info["area"]]

    def shade(f):
        t = 0.5 if fmax == fmin else (f - fmin) / (fmax - fmin)
        g = int(150 + t * 90)  # low = darker grey, high = lighter
        return "#%02x%02x%02x" % (g, g, int(g * 0.97))

    defs, floor_uses, area_uses, door_uses, lift_uses, secret_uses = [], [], [], [], [], []
    sect_pts = []
    for i, sl in enumerate(loops):
        pts_loops = [[V[k] for k in l] for l in sl]
        sect_pts.append(pts_loops)
        if not sl:
            continue
        d = "".join("M" + "L".join(P(k) for k in l[:-1]) + "Z" for l in sl)
        defs.append('<path id="s%d" d="%s"/>' % (i, d))
        floor_uses.append('<use href="#s%d" data-s="%d" fill="%s"/>' % (i, i, shade(m.sectors[i]["floor"])))
        a = info["area"][i]
        if a >= 0:
            area_uses.append('<use href="#s%d" fill="%s"/>' % (i, area_color(a)))
        if i in info["door_secs"]:
            door_uses.append('<use href="#s%d"/>' % i)
        if i in info["lift_secs"]:
            lift_uses.append('<use href="#s%d"/>' % i)
        if m.sectors[i]["secret"]:
            secret_uses.append('<use href="#s%d"/>' % i)

    one, two, sound = [], [], []
    door_lines, lift_lines, trig_lines, exit_lines, tele_lines = [], [], [], [], []
    for li, ln in enumerate(m.lines):
        if ln["v1"] >= len(V) or ln["v2"] >= len(V):
            continue
        seg = "M%sL%s" % (P(ln["v1"]), P(ln["v2"]))
        (two if ln["bs"] >= 0 else one).append(seg)
        if ln["blocksound"]:
            sound.append(seg)
        a = ln["act"]
        if not a:
            continue
        trig, kind, txt = a
        title = "Line %d: %s %s, special %d, tag %d" % (li, trig, txt, ln["special"], ln["tag"])
        if kind == "door" and trig[0] == "D":
            door_lines.append('<path d="%s"><title>%s</title></path>' % (seg, html.escape(title)))
        elif kind == "lift" and trig[0] == "D":
            lift_lines.append('<path d="%s"><title>%s</title></path>' % (seg, html.escape(title)))
        elif kind in ("door", "lift", "floor", "ceiling", "stairs", "crusher", "donut"):
            cls = "walk" if trig[0] in "WM" else ("shoot" if trig[0] == "G" else "use")
            trig_lines.append('<path class="%s %s" d="%s"><title>%s</title></path>'
                              % (cls, kind, seg, html.escape(title)))
        elif kind == "exit":
            exit_lines.append('<path d="%s"><title>%s</title></path>' % (seg, html.escape(title)))
        elif kind == "teleport":
            tele_lines.append('<path d="%s"><title>%s</title></path>' % (seg, html.escape(title)))

    # area labels
    labels = []
    area_info = []
    for aid, members in enumerate(info["areas"]):
        big = max(members, key=lambda s: loops_area(sect_pts[s]) if s < len(sect_pts) else 0)
        pl = sect_pts[big] if big < len(sect_pts) else []
        p = label_point(pl) if pl else None
        tot = info["area_size"][aid]
        area_info.append(dict(n=len(members), size=round(tot)))
        if p and tot > 0:
            labels.append('<text x="%s" y="%s" data-z="%d">%d</text>' % (fmt(p[0]), fmt(-p[1]), math.sqrt(tot), aid))

    # things
    things = []
    sect_area = info["area"]
    mon_count = 0
    for t in m.things:
        typ = t["type"]
        sk = "".join(str(k) for k in sorted(t["skills"]))
        mp = ' data-mp="1"' if t["mp_only"] else ""
        x, y = fmt(t["x"]), fmt(-t["y"])
        if typ in MONSTERS:
            name, tier = MONSTERS[typ]
            mon_count += 1
            things.append('<circle class="th mon t%d" cx="%s" cy="%s" data-k="%s"%s><title>%s (%d), skills %s%s</title></circle>'
                          % (tier, x, y, sk, mp, name, typ, sk or "none", ", multiplayer only" if mp else ""))
        elif typ in KEYS:
            name, col = KEYS[typ]
            things.append('<circle class="th key" cx="%s" cy="%s" fill="%s" data-k="%s"%s><title>%s</title></circle>'
                          % (x, y, col, sk, mp, name))
        elif typ in STARTS:
            things.append('<g class="start" transform="translate(%s %s) rotate(%d)"><path class="startmark" d="M1.3 0L-0.9 -0.9L-0.4 0L-0.9 0.9Z"/>'
                          '<title>%s start</title></g>' % (x, y, -t["angle"], STARTS[typ]))

    sectors_json = [[s["floor"], s["ceil"], s["light"], s["special"], s["tag"], info["area"][i]]
                    for i, s in enumerate(m.sectors)]
    pad = 64
    vb = [minx - pad, -maxy - pad, (maxx - minx) + 2 * pad, (maxy - miny) + 2 * pad]
    svg = []
    svg.append('<svg id="map" xmlns="http://www.w3.org/2000/svg" viewBox="%s">' % " ".join(fmt(float(v)) for v in vb))
    svg.append("<defs>%s</defs>" % "".join(defs))
    svg.append('<g id="L_floor">%s</g>' % "".join(floor_uses))
    svg.append('<g id="L_areas" class="layer">%s</g>' % "".join(area_uses))
    svg.append('<g id="L_secret" class="layer">%s</g>' % "".join(secret_uses))
    svg.append('<g id="L_door" class="layer"><g class="secs">%s</g><g class="secs lift">%s</g></g>'
               % ("".join(door_uses), "".join(lift_uses)))
    svg.append('<path id="L_two" d="%s"/>' % "".join(two))
    svg.append('<path id="L_one" d="%s"/>' % "".join(one))
    svg.append('<g id="L_doorlines" class="layer"><g class="dl">%s</g><g class="ll">%s</g></g>'
               % ("".join(door_lines), "".join(lift_lines)))
    svg.append('<g id="L_trig" class="layer">%s</g>' % "".join(trig_lines))
    svg.append('<path id="L_sound" class="layer" d="%s"/>' % "".join(sound))
    svg.append('<g id="L_exit" class="layer">%s<g class="tele">%s</g></g>' % ("".join(exit_lines), "".join(tele_lines)))
    svg.append('<g id="L_alabels" class="layer">%s</g>' % "".join(labels))
    svg.append('<g id="L_things" class="layer">%s</g>' % "".join(things))
    svg.append('<g id="rects"></g>')
    svg.append("</svg>")

    meta = dict(wad=wadname, map=mapname, fmt=m.fmt, bounds=[minx, miny, maxx, maxy],
                counts=dict(sectors=len(m.sectors), lines=len(m.lines), things=len(m.things),
                            monsters=mon_count, areas=len(info["areas"]),
                            soundlines=len(sound), doorsecs=len(info["door_secs"]),
                            liftsecs=len(info["lift_secs"]),
                            secrets=sum(1 for s in m.sectors if s["secret"])))
    page = template.replace("%%TITLE%%", html.escape("%s %s" % (wadname, mapname)))
    page = page.replace("%%SVG%%", "\n".join(svg))
    page = page.replace("%%META%%", json.dumps(meta))
    page = page.replace("%%SECTORS%%", json.dumps(sectors_json, separators=(",", ":")))
    page = page.replace("%%AREAS%%", json.dumps(area_info, separators=(",", ":")))
    return page, meta


def write_index(outdir, entries, title):
    rows = []
    for e in entries:
        c = e["counts"]
        rows.append('<tr><td><a href="%s">%s</a></td><td>%s</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td></tr>'
                    % (html.escape(e["href"]), html.escape(e["map"]), e["fmt"], c["sectors"], c["lines"],
                       c["monsters"], c["areas"], c["soundlines"]))
    page = """<!doctype html><meta charset="utf-8"><title>%s</title>
<style>body{font:14px system-ui,sans-serif;margin:24px;background:#f4f1ea}table{border-collapse:collapse}
td,th{padding:4px 12px;border-bottom:1px solid #ccc;text-align:right}td:first-child,th:first-child{text-align:left}
a{font-weight:bold}</style><h1>%s</h1>
<table><tr><th>Map</th><th>Format</th><th>Sectors</th><th>Lines</th><th>Monsters</th><th>Areas</th><th>Sound-block lines</th></tr>
%s</table>""" % (html.escape(title), html.escape(title), "\n".join(rows))
    with open(os.path.join(outdir, "index.html"), "w", encoding="utf-8") as f:
        f.write(page)


def main():
    ap = argparse.ArgumentParser(description="Top-down Doom map pages with room rectangles.")
    ap.add_argument("wads", nargs="+", help="WAD or PK3 files")
    ap.add_argument("-o", "--out", default="mapview_out", help="output folder")
    ap.add_argument("--maps", default="", help="comma list, e.g. MAP01,MAP07 (default all)")
    args = ap.parse_args()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "template.html"), encoding="utf-8") as f:
        template = f.read()
    want = {x.strip().upper() for x in args.maps.split(",") if x.strip()}
    os.makedirs(args.out, exist_ok=True)
    top = []
    for wad in args.wads:
        wadname = os.path.basename(wad)
        stem = re.sub(r"[^A-Za-z0-9_.-]", "_", os.path.splitext(wadname)[0])
        sub = os.path.join(args.out, stem)
        os.makedirs(sub, exist_ok=True)
        entries = []
        for mapname, lumps in load_source(wad):
            if want and mapname not in want:
                continue
            m = parse_map(lumps)
            res = build_html(wadname, mapname, m, template)
            if not res:
                print("  %s: no vertices, skipped" % mapname)
                continue
            page, meta = res
            fn = "%s.html" % mapname
            with open(os.path.join(sub, fn), "w", encoding="utf-8") as f:
                f.write(page)
            meta["href"] = fn
            entries.append(meta)
            c = meta["counts"]
            print("  %s %-6s %-5s sectors %4d  lines %5d  monsters %3d  areas %3d"
                  % (wadname, mapname, m.fmt, c["sectors"], c["lines"], c["monsters"], c["areas"]))
        write_index(sub, entries, wadname)
        top.append((stem, wadname, len(entries)))
    # top-level index over every WAD folder present
    rows = []
    for d in sorted(os.listdir(args.out)):
        if os.path.isfile(os.path.join(args.out, d, "index.html")):
            n = len([x for x in os.listdir(os.path.join(args.out, d)) if x.endswith(".html")]) - 1
            rows.append('<li><a href="%s/index.html">%s</a> (%d maps)</li>' % (html.escape(d), html.escape(d), n))
    with open(os.path.join(args.out, "index.html"), "w", encoding="utf-8") as f:
        f.write('<!doctype html><meta charset="utf-8"><title>Map view</title>'
                '<style>body{font:15px system-ui,sans-serif;margin:24px;background:#f4f1ea}</style>'
                '<h1>Map view</h1><ul>%s</ul>' % "".join(rows))
    print("wrote %s" % os.path.join(args.out, "index.html"))


if __name__ == "__main__":
    main()
