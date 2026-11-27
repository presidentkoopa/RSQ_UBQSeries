#!/usr/bin/env python3
"""Draw the How To Play page as the game would, for the owner to look at before a headset does.

    python3 tools/howtoplay/preview.py            writes design/howtoplay_preview/*.png

Every number comes from the code: the layout constants and the figure's chips from tools/howtoplay/howto_template.zs,
the rows from each mod's generated howto_data.zs (RSQ Score's from its glossary_data.zs, as its tab reads them), the
letters from RSQ Score's own fonts (RSSCFON / RSSCFN2, FON2) and the colours from its TEXTCOLO. It follows the page's
Drawer step by step. Assumed for the pictures: every series mod loaded, RSQ Tactical Rig on with BD22 VR Reloaded's hand
(so every Show row is listed), right-handed, no key bound but the Wheel's default.
"""
import os
import re
import struct
import sys

from PIL import Image, ImageDraw

HUB = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_howtoplay as gen  # noqa: E402

OUT = os.path.join(HUB, "design", "howtoplay_preview")
S = 2.0   # 640 x 400 virtual -> 1280 x 800


# ---------------------------------------------------------------------------------------------------- the code's numbers
TPL = open(gen.TEMPLATE, encoding="utf-8").read()
MENU = TPL[TPL.find("class @P@_HowToMenu"):TPL.find("class OptionMenuItem@P@HowToLink")]
C = {m.group(1): float(m.group(2)) for m in re.finditer(r"const (\w+) = ([\d.]+);", MENU)}
def arr(name, kind=str):
    m = re.search(r"static const \w+ %s\[\] = \{([^}]*)\}" % name, MENU)
    items = re.findall(r'"([^"]*)"', m.group(1)) if kind is str else [int(x) for x in re.findall(r"-?\d+", m.group(1))]
    return items
PLACES, PLACENAME = arr("PLACES"), arr("PLACENAME")
CHIPX, CHIPY, CHIPW = arr("CHIPX", int), arr("CHIPY", int), arr("CHIPW", int)
FIG = arr("FIG", int)
CONSTS = {m.group(1): m.group(2) for m in re.finditer(r'const (\w+) = "([^"]*)";', MENU)}


# ---------------------------------------------------------------------------------------------------- fonts and colours
class Fon2:
    def __init__(self, path):
        d = open(path, "rb").read()
        self.h = struct.unpack("<H", d[4:6])[0]
        first, last, const, flags, pal = d[6], d[7], d[8], d[11], d[10]
        p, self.kern = 12, 0
        if flags & 1:
            self.kern = struct.unpack("<h", d[p:p + 2])[0]; p += 2
        n = last - first + 1
        if const:
            w = [struct.unpack("<H", d[p:p + 2])[0]] * n; p += 2
        else:
            w = list(struct.unpack("<%dH" % n, d[p:p + 2 * n])); p += 2 * n
        palette = [tuple(d[p + 3 * i:p + 3 * i + 3]) for i in range(pal + 1)]; p += 3 * (pal + 1)
        lum = [0.299 * r + 0.587 * g + 0.114 * b for r, g, b in palette]
        lo, hi = min(lum[1:]), max(lum[1:])
        self.lum = [int(255 * (l - lo) / max(1, hi - lo)) for l in lum]
        self.w, self.g, self.first = {}, {}, first
        for i in range(n):
            c = first + i
            self.w[c] = w[i]
            if w[i] == 0:
                continue
            size, out = w[i] * self.h, bytearray()
            while len(out) < size:
                code = struct.unpack("b", d[p:p + 1])[0]; p += 1
                if code >= 0:
                    out += d[p:p + code + 1]; p += code + 1
                elif code != -128:
                    out += bytes([d[p]]) * (-code + 1); p += 1
            self.g[c] = bytes(out[:size])

    def cw(self, ch):
        return self.w.get(ord(ch), self.w.get(32, 4))

    def width(self, t):
        return sum(self.cw(ch) + self.kern for ch in t)

    def lines(self, t, maxw):
        words, out, cur = t.split(" "), [], ""
        for wd in words:
            test = (cur + " " + wd) if cur else wd
            if self.width(test) <= maxw or not cur:
                cur = test
            else:
                out.append(cur); cur = wd
        if cur:
            out.append(cur)
        return out


def textcolo():
    t = open(os.path.join(HUB, "Score", "TEXTCOLO.txt")).read()
    t = re.sub(r"//[^\n]*", "", t)
    cols = {}
    for m in re.finditer(r"(\w+)\s*\{([^}]*)\}", t):
        segs = []
        for mm in re.finditer(r"#([0-9A-Fa-f]{6})\s+#([0-9A-Fa-f]{6})\s+(\d+)\s+(\d+)", m.group(2)):
            a, b = [tuple(int(x[i:i + 2], 16) for i in (0, 2, 4)) for x in (mm.group(1), mm.group(2))]
            segs.append((int(mm.group(3)), int(mm.group(4)), a, b))
        cols[m.group(1)] = segs
    return cols


COLS = textcolo()
BIG = Fon2(os.path.join(HUB, "Score", "RSSCFON.fon2"))
SMALL = Fon2(os.path.join(HUB, "Score", "RSSCFN2.fon2"))


def shade(colname, l):
    for lo, hi, a, b in COLS.get(colname, COLS["RSScore_White"]):
        if lo <= l <= hi:
            f = (l - lo) / max(1, hi - lo)
            return tuple(int(a[i] + (b[i] - a[i]) * f) for i in range(3))
    return (255, 255, 255)


class Page:
    def __init__(self):
        self.im = Image.new("RGB", (int(640 * S), int(400 * S)), (8, 8, 8))
        self.dr = ImageDraw.Draw(self.im)

    def box(self, rgb, a, x, y, w, h):
        c = tuple(int(((rgb >> s) & 255) * a) for s in (16, 8, 0))
        self.dr.rectangle([int(x * S), int(y * S), int((x + w) * S) - 1, int((y + h) * S) - 1], fill=c)

    def txt(self, f, col, x, y, t, k=1.0, alpha=1.0, kx=0):
        kx = kx or k
        cx = x
        for ch in t:
            c = ord(ch)
            if c in f.g:
                w = f.w[c]
                g = Image.new("RGBA", (w, f.h), (0, 0, 0, 0))
                px = g.load()
                for yy in range(f.h):
                    for xx in range(w):
                        v = f.g[c][yy * w + xx]
                        if v:
                            r, gg, b = shade(col, f.lum[v])
                            px[xx, yy] = (r, gg, b, int(255 * alpha))
                gw, gh = max(1, round(w * S * kx)), max(1, round(f.h * S * k))
                g = g.resize((gw, gh), Image.BILINEAR)
                self.im.paste(g, (round(cx * S), round(y * S)), g)
            cx += (f.cw(ch) + f.kern) * kx

    def fit(self, f, col, x, y, w, t, k, least=0.6, alpha=1.0):
        tw = f.width(t) * k
        if tw <= w:
            return self.txt(f, col, x, y, t, k, alpha)
        kx = k * w / max(1, tw)
        if kx >= k * least:
            return self.txt(f, col, x, y, t, k, alpha, kx)
        kx = k * least
        c = t
        while len(c) > 1 and f.width(c + "..") * kx > w:
            c = c[:-1]
        self.txt(f, col, x, y, c + "..", k, alpha, kx)

    def para(self, f, col, x, y, w, t, k, draw=True):
        lh = f.h * k + 3
        for l in f.lines(t, w / k):
            if draw:
                self.txt(f, col, x, y, l, k)
            y += lh
        return y

    def labeled(self, f, lc, vc, x, y, w, label, val, k, draw=True):
        lw = f.width(label + " ") * k
        if draw:
            self.txt(f, lc, x, y, label, k)
        lh = f.h * k + 3
        ls = f.lines(val, max(w - lw, 40) / k)
        for l in ls:
            if draw:
                self.txt(f, vc, x + lw, y, l, k)
            y += lh
        return y if ls else y + lh


# ---------------------------------------------------------------------------------------------------- the rows, as Build makes them
def unz(s):
    return s.replace('\\"', '"').replace("\\\\", "\\")


def mod_tabs():
    tabs = []
    for mod in gen.MODS:
        folder, prefix, zsdir, stem = mod[:4]
        t = open(os.path.join(HUB, zsdir, stem + "howto_data.zs"), encoding="utf-8").read()
        tab = re.search(r'const TAB = "([^"]*)"', t).group(1)
        col = re.search(r'const COLOUR = "([^"]*)"', t).group(1)
        rank = int(re.search(r"const RANK = (\d+);", t).group(1))
        rows = [unz(m.group(1)) for m in re.finditer(r'r\.Push\("((?:[^"\\]|\\.)*)"\);', t)]
        if folder == "Score":
            rows = glossary_rows()
        tabs.append((rank, prefix, tab, col, rows, folder))
    tabs.sort(key=lambda x: (x[0], x[1]))
    return tabs


def glossary_rows():
    g = open(os.path.join(HUB, "Score", "zscript", "rsscore", "glossary.zs")).read()
    fam = re.findall(r'"([^"]+)"', re.search(r"FAMNAME\[\]\s*=\s*\{([^}]*)\}", g).group(1))
    fcol = re.findall(r'"([^"]+)"', re.search(r"FAMCOLOR\[\]\s*=\s*\{([^}]*)\}", g).group(1))
    d = open(os.path.join(HUB, "Score", "zscript", "rsscore", "glossary_data.zs"), encoding="utf-8").read()
    out = []
    for m in re.finditer(r'Add\((\d+), "((?:[^"\\]|\\.)*)", "((?:[^"\\]|\\.)*)", "((?:[^"\\]|\\.)*)", "((?:[^"\\]|\\.)*)"\);', d):
        f = int(m.group(1)); name, text, bonus, needs = [unz(m.group(i)).upper() for i in range(2, 6)]
        mm = re.search(r"\+\d+", bonus)
        short = mm.group(0) if mm else ""
        out.append("|".join([fam[f].upper(), fcol[f], name, short, "", "", text, "BONUS:~%s~NEEDS:~%s" % (bonus, needs)]))
    return out


DEFAULT_KEYS = {"+wr_wheel": "LTHUMB"}


def build():
    tabs = mod_tabs()
    T = [dict(name="BODY", col="RSScore_Counter", body=True)] + [dict(name=t[2], col=t[3], body=False) for t in tabs]
    R = []
    def add(**kw):
        R.append(kw)
    for ti, t in enumerate(tabs, start=1):
        for raw in t[4]:
            f = raw.split("|") + [""] * 8
            val = f[3]
            pairs = f[7]
            if val.startswith("KEY:"):
                kn = DEFAULT_KEYS.get(val[4:], "NOT BOUND")
                pairs += "~KEY:~" + kn
                val = kn
            col = f[1] or T[ti]["col"]
            add(tab=ti, kind=0, sec=f[0], col=col, label=f[2], value=val, places=f[4], demo=f[5], para=f[6], pairs=pairs)
            if f[5] and f[5] != "shield":
                do = [p for p in [pairs.split("~")[i:i + 2] for i in range(0, len(pairs.split("~")), 2)] if p[0] == "DO:"]
                add(tab=ti, kind=1, sec=f[0], col=col, label=CONSTS["SHOWME"], value="", places="", demo=f[5],
                    para=CONSTS["SHOWME_TEXT"], pairs="~".join(do[0]) if do else "")
    n = len(R)
    hand = {"MSH": "RSH", "OSH": "LSH", "MHIP": "RHIP", "OHIP": "LHIP"}
    for pl in PLACES:
        first = len(R)
        for i in range(n):
            r = R[i]
            if r["kind"] or pl not in [hand.get(q, q) for q in r["places"].split()]:
                continue
            ps = r["pairs"].split("~")
            body = "~".join(sum([ps[k:k + 2] for k in range(0, len(ps) - 1, 2) if ps[k] in ("DO:", "GET:")], []))
            add(tab=0, kind=0, sec=pl, col=r["col"], label=r["label"], value=T[r["tab"]]["name"], places=r["places"], demo=r["demo"], para="", pairs=body)
            if r["demo"] and r["demo"] != "shield":
                do = [ps[k:k + 2] for k in range(0, len(ps) - 1, 2) if ps[k] == "DO:"]
                add(tab=0, kind=1, sec=pl, col=r["col"], label=CONSTS["SHOWME"], value=T[r["tab"]]["name"], places="", demo=r["demo"],
                    para=CONSTS["SHOWME_TEXT"], pairs="~".join(do[0]) if do else "")
        if len(R) > first:
            R.insert(first, dict(tab=0, kind=2, sec=pl, col="RSScore_Counter", label=CONSTS["SHOWBODY"], value="", places=pl, demo="",
                                 para=CONSTS["SHOWBODY_TEXT"], pairs=""))
    stops = []
    for ti in range(len(T)):
        secs = []
        for r in R:
            if r["tab"] == ti and r["sec"] not in secs:
                secs.append(r["sec"])
        for s in secs or [""]:
            stops.append((ti, s))
    return T, R, stops


# ---------------------------------------------------------------------------------------------------- the Drawer
def draw(T, R, stops, stop, sel):
    P = Page()
    VW, VH = C["VW"], C["VH"]
    LISTX, LISTW, DX, ROWH, LS, TS, TSMIN = C["LISTX"], C["LISTW"], C["DX"], C["ROWH"], C["LS"], C["TS"], C["TSMIN"]
    TABY, TABH, TABSHOWN, ARROW, SECY, SECH, PANELB = C["TABY"], C["TABH"], int(C["TABSHOWN"]), C["ARROW"], C["SECY"], C["SECH"], C["PANELB"]
    BODYROWH, BODYROWS = C["BODYROWH"], int(C["BODYROWS"])
    ct, sec = stops[stop]
    shown = [i for i, r in enumerate(R) if r["tab"] == ct and r["sec"] == sec]
    nsec = sum(1 for s in stops if s[0] == ct)
    body = T[ct]["body"]
    rows = BODYROWS if body else (8 if nsec > 1 else 9)
    rowh = BODYROWH if body else ROWH
    ly = 118 if body else (124 if nsec > 1 else 100)
    top = max(0, min(sel - rows + 1, len(shown) - rows)) if sel >= rows else 0
    first = max(0, min(ct - TABSHOWN + 1, len(T) - TABSHOWN)) if ct >= TABSHOWN else 0

    P.txt(BIG, "RSScore_Gold", (VW - BIG.width("HOW TO RIP AND TEAR") * 1.4) / 2, 12, "HOW TO RIP AND TEAR", 1.4)
    nt = len(T)
    if nt > TABSHOWN:
        x0, tw = LISTX + ARROW, (VW - 2 * LISTX - 2 * ARROW) / TABSHOWN
    else:
        x0, tw = LISTX, (VW - 2 * LISTX) / max(nt, 1)
    for i in range(min(nt, TABSHOWN)):
        t = first + i
        tx = x0 + i * tw
        on = t == ct
        if on:
            P.box(0x606060, 0.6, tx + 2, TABY, tw - 4, TABH); P.box(0xFFFFFF, 0.8, tx + 2, TABY + TABH - 2, tw - 4, 2)
        else:
            P.box(0x303030, 0.6, tx + 2, TABY, tw - 4, TABH)
        nm = T[t]["name"]
        k = min(1.25, (tw - 12) / max(1, SMALL.width(nm)))
        P.txt(SMALL, T[t]["col"], tx + (tw - SMALL.width(nm) * k) / 2, TABY + TABH / 2 - SMALL.h * k / 2, nm, k, 1.0 if on else 0.55)
    if nt > TABSHOWN:
        m0, m1 = first > 0, first + TABSHOWN < nt
        ak = 1.4
        P.txt(SMALL, "RSScore_Gold" if m0 else "RSScore_White", LISTX + (ARROW - SMALL.width("<") * ak) / 2, TABY + TABH / 2 - SMALL.h * ak / 2, "<", ak, 1.0 if m0 else 0.25)
        P.txt(SMALL, "RSScore_Gold" if m1 else "RSScore_White", VW - LISTX - ARROW + (ARROW - SMALL.width(">") * ak) / 2, TABY + TABH / 2 - SMALL.h * ak / 2, ">", ak, 1.0 if m1 else 0.25)

    def detail(e, x, y, w, notitle):
        r = R[e]
        nm = r["label"]
        nk = min(1.0, (w - 4) / max(1, BIG.width(nm)))
        if not notitle and nk >= 0.75:
            P.txt(BIG, r["col"], x, y, nm, nk); y += BIG.h * nk + 10
        p = r["pairs"].split("~") if r["pairs"] else []
        k = TS
        while k > TSMIN:
            yy = y
            if r["para"]:
                yy = P.para(SMALL, "RSScore_White", x, yy, w, r["para"], k, False) + 10
            for i in range(0, len(p) - 1, 2):
                yy = P.labeled(SMALL, "RSScore_Gold", "RSScore_White", x, yy, w, p[i], p[i + 1], k, False) + 6
            if yy <= PANELB - 2:
                break
            k -= 0.1
        k = max(k, TSMIN)
        if r["para"]:
            y = P.para(SMALL, "RSScore_White", x, y, w, r["para"], k) + 10
        for i in range(0, len(p) - 1, 2):
            y = P.labeled(SMALL, "RSScore_Gold", "RSScore_White", x, y, w, p[i], p[i + 1], k) + 6
        return k

    def scrollbar(x, y):
        if len(shown) <= rows:
            return
        bh = rows * rowh
        th = max(12.0, bh * rows / len(shown))
        tyb = y + (bh - th) * top / (len(shown) - rows)
        P.box(0x404040, 1.0, x, y, 5, bh); P.box(0xC0C0C0, 1.0, x, tyb, 5, th)

    if not body:
        if nsec > 1:
            f0 = [i for i, s in enumerate(stops) if s[0] == ct][0]
            sw = (VW - 2 * LISTX) / nsec
            for k in range(nsec):
                sx = LISTX + k * sw
                on = f0 + k == stop
                if on:
                    P.box(0x606060, 0.6, sx + 2, SECY, sw - 4, SECH); P.box(0xFFFFFF, 0.8, sx + 2, SECY + SECH - 2, sw - 4, 2)
                else:
                    P.box(0x303030, 0.6, sx + 2, SECY, sw - 4, SECH)
                nm = stops[f0 + k][1]
                col = next((r["col"] for r in R if r["tab"] == ct and r["sec"] == nm), "RSScore_White")
                kk = min(1.1, (sw - 10) / max(1, SMALL.width(nm)))
                P.txt(SMALL, col, sx + (sw - SMALL.width(nm) * kk) / 2, SECY + SECH / 2 - SMALL.h * kk / 2, nm, kk, 1.0 if on else 0.55)
        P.box(0x202020, 0.7, LISTX, ly - 6, LISTW, rows * ROWH + 12)
        lh = SMALL.h * LS
        for rr in range(rows):
            if top + rr >= len(shown):
                break
            i = shown[top + rr]; r = R[i]
            ry = ly + rr * ROWH
            if top + rr == sel:
                P.box(0x707070, 0.55, LISTX + 2, ry - 2, LISTW - 14, ROWH - 2)
            fc = "RSScore_Gold" if r["kind"] else r["col"]
            vw = SMALL.width(r["value"]) * 1.0 if r["value"] else 0
            room = LISTW - 30 - (vw + 8 if vw > 0 else 0)
            nw = SMALL.width(r["label"]) * LS
            if nw * 0.75 <= room or r["kind"]:
                P.fit(SMALL, fc, LISTX + 8, ry + (ROWH - 2 - lh) / 2 - 2, room, r["label"], LS, 0.75)
            else:
                k2 = 1.0; h2 = SMALL.h * k2
                bl = SMALL.lines(r["label"], room / k2)
                ty = ry + (ROWH - 2 - (2 * h2 + 2)) / 2 - 1
                P.fit(SMALL, fc, LISTX + 8, ty, room, bl[0], k2, 0.8)
                if len(bl) > 1:
                    P.fit(SMALL, fc, LISTX + 8, ty + h2 + 2, room, " ".join(bl[1:]), k2, 0.8)
            if vw > 0:
                P.txt(SMALL, "RSScore_White", LISTX + LISTW - 20 - vw, ry + (ROWH - 2 - SMALL.h) / 2 - 2, r["value"], 1.0)
        scrollbar(LISTX + LISTW - 9, ly)
        dw = VW - LISTX - DX
        P.box(0x202020, 0.7, DX - 6, ly - 6, dw + 6, PANELB - ly + 6)
        k = detail(shown[sel], DX + 4, ly + 2, dw - 12, False)
    else:
        here = sec
        P.box(0x202020, 0.7, LISTX, 94, LISTW, PANELB - 94)
        for b in range(0, len(FIG) - 3, 4):
            P.box(0x3A3A3A, 1.0, FIG[b], FIG[b + 1], FIG[b + 2], FIG[b + 3])
        for pl in range(len(PLACES)):
            has = any(s == (ct, PLACES[pl]) for s in stops)
            on = PLACES[pl] == here
            cx, cy, cw = CHIPX[pl], CHIPY[pl], CHIPW[pl]
            P.box(0x909090 if on else 0x505050, 1.0, cx - cw / 2 - 1, cy - 11, cw + 2, 22)
            if on:
                P.box(0x606060, 0.9, cx - cw / 2, cy - 10, cw, 20); P.box(0xFFFFFF, 0.8, cx - cw / 2, cy + 8, cw, 2)
            else:
                P.box(0x101010, 1.0, cx - cw / 2, cy - 10, cw, 20)
            nm = PLACENAME[pl]
            kk = min(1.0, (cw - 6) / max(1, SMALL.width(nm)))
            P.txt(SMALL, "RSScore_Gold" if on else "RSScore_White", cx - SMALL.width(nm) * kk / 2, cy - SMALL.h * kk / 2, nm, kk, 1.0 if on else (0.8 if has else 0.25))
        dw = VW - LISTX - DX
        P.box(0x202020, 0.7, DX - 6, 94, dw + 6, PANELB - 94)
        moves = sum(1 for i in shown if R[i]["kind"] == 0)
        head = "%s: %d %s" % (PLACENAME[PLACES.index(here)], moves, "MOVE" if moves == 1 else "MOVES")
        P.fit(SMALL, T[ct]["col"], DX + 2, 98, dw - 8, head, 1.25)
        for rr in range(rows):
            if top + rr >= len(shown):
                break
            i = shown[top + rr]; r = R[i]
            ry = ly + rr * BODYROWH
            if top + rr == sel:
                P.box(0x707070, 0.55, DX - 4, ry - 2, dw - 6, BODYROWH - 2)
            vw = SMALL.width(r["value"]) * 0.9 if r["value"] else 0
            room = dw - 16 - (vw + 8 if vw > 0 else 0)
            P.fit(SMALL, "RSScore_Gold" if r["kind"] else r["col"], DX + 2, ry + (BODYROWH - 2 - SMALL.h * 1.2) / 2 - 1, room, r["label"], 1.2, 0.6)
            if vw > 0:
                P.txt(SMALL, "RSScore_White", DX + dw - 12 - vw, ry + (BODYROWH - 2 - SMALL.h * 0.9) / 2 - 1, r["value"], 0.9, 0.8)
        scrollbar(DX + dw - 7, ly)
        dy = ly + rows * BODYROWH + 6
        P.box(0x404040, 1.0, DX, dy - 4, dw - 8, 1)
        k = detail(shown[sel], DX + 2, dy + 2, dw - 10, True)

    show = R[shown[sel]]["kind"] != 0
    hint = ("UP/DOWN: CHOOSE     LEFT/RIGHT: TAB     SELECT: SHOW     BACK: CLOSE" if show
            else "UP/DOWN: CHOOSE     LEFT/RIGHT: TAB     BACK: CLOSE")
    P.txt(SMALL, "RSScore_White", (VW - SMALL.width(hint) * 1.1) / 2, VH - 22, hint, 1.1, 0.75)
    return P.im, k


def main():
    os.makedirs(OUT, exist_ok=True)
    T, R, stops = build()
    def stop_of(tabname, sec=""):
        ti = [i for i, t in enumerate(T) if t["name"] == tabname][0]
        return [i for i, s in enumerate(stops) if s[0] == ti and (sec == "" or s[1] == sec)][0]
    def sel_of(st, label_start, kind=0):
        ct, sec = stops[st]
        shown = [i for i, r in enumerate(R) if r["tab"] == ct and r["sec"] == sec]
        return [n for n, i in enumerate(shown) if R[i]["kind"] == kind and R[i]["label"].startswith(label_start)][0]
    shots = [
        ("howtoplay_mod_tab_tactical_rig.png", stop_of("TACTICAL RIG"), "HOLD A GUN IN THE MAIN HAND INSIDE", 0),
        ("howtoplay_mod_tab_tactical_rig_showme.png", stop_of("TACTICAL RIG"), "SHOW ME", 1),
        ("howtoplay_body_tab_right_hip.png", stop_of("BODY", "RHIP"), "SQUEEZE THE MAIN GRIP AT THE SPOT JUST BELOW", 0),
        ("howtoplay_body_tab_chest_show_on_body.png", stop_of("BODY", "CHEST"), "SHOW ON MY BODY", 2),
        ("howtoplay_score_tab_glossary.png", stop_of("SCORE", "STYLE"), "AIR", 0),
        ("howtoplay_mod_tab_wheel_key.png", stop_of("WHEEL"), "PRESS OPEN WHEEL", 0),
    ]
    for name, st, lab, kind in shots:
        im, k = draw(T, R, stops, st, sel_of(st, lab, kind))
        im.save(os.path.join(OUT, name))
        print("wrote design/howtoplay_preview/%s (detail text at %.1f)" % (name, k))
    print("tabs:", " | ".join(t["name"] for t in T))


if __name__ == "__main__":
    main()
