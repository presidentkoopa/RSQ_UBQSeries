#!/usr/bin/env python3
"""Glyph sample sheets for design/ARCADE_ASSETS_INVENTORY.md, rendered from the real files (no mod code is touched).

  python3 -I design/mockups/fonts/make_font_sheets.py [path/to/doom2.wad] [path/to/brutal22test6.pk3]

Reads: Score/*.fon2 (FON2 decoded here), the JFO / Ermac / damnums PNGs the series ships or keeps as sources,
the IWAD's patches (STCFN, STTNUM, STYSNUM, STGNUM, WINUM) and DBIGFONT (FON2) through PLAYPAL, BD22's
graphics/HUDS/Font PNGs, and the DOWN seven-segment readout redrawn from SlowMo/zscript/rsqsm/downhud.zs's own
segment table. Writes one PNG per font and contact_sheet.png next to this file."""
import io, os, struct, sys, zipfile
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
WAD = sys.argv[1] if len(sys.argv) > 1 else '/home/claude/gamedata/doom2.wad'
BD = sys.argv[2] if len(sys.argv) > 2 else '/home/claude/gamedata/brutal22test6.pk3'
BG = (18, 18, 22, 255)
INK = (200, 200, 205)


# ---- readers -------------------------------------------------------------------------------------------------------
def fon2(data, pal_override=None):
    """FON2 (the engine's FSingleLumpFont::LoadFON2): {code: RGBA image}, height"""
    assert data[:4] == b'FON2'
    h = data[4] | (data[5] << 8)
    first, last, mono, active = data[6], data[7], data[8], data[10] + 1
    p = 14 if data[11] & 1 else 12
    count = last - first + 1
    if mono:
        widths = [struct.unpack_from('<H', data, p)[0]] * count; p += 2
    else:
        widths = list(struct.unpack_from('<%dH' % count, data, p)); p += 2 * count
    pal = [tuple(data[p + 3 * i:p + 3 * i + 3]) for i in range(active)]; p += 3 * active
    out = {}
    for i in range(count):
        w = widths[i]
        if w == 0:
            continue
        n = w * h; px = bytearray()
        while len(px) < n:
            c = data[p]; p += 1
            if c >= 128: c -= 256
            if c >= 0:
                px += data[p:p + c + 1]; p += c + 1
            elif c != -128:
                px += bytes([data[p]]) * (1 - c); p += 1
        im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        for y in range(h):
            for x in range(w):
                k = px[y * w + x]
                if k:
                    r, g, b = pal[k] if k < len(pal) else (255, 0, 255)
                    im.putpixel((x, y), (r, g, b, 255))
        out[first + i] = im
    return out, h


class Wad:
    def __init__(self, path):
        self.d = open(path, 'rb').read()
        _, n, o = struct.unpack('<4sii', self.d[:12])
        self.dir = {}
        for i in range(n):
            pos, size = struct.unpack('<ii', self.d[o + 16 * i:o + 16 * i + 8])
            name = self.d[o + 16 * i + 8:o + 16 * i + 16].rstrip(b'\0').decode('latin1')
            self.dir.setdefault(name, (pos, size))
        pos, _ = self.dir['PLAYPAL']
        self.pal = [tuple(self.d[pos + 3 * i:pos + 3 * i + 3]) for i in range(256)]

    def lump(self, name):
        if name not in self.dir: return None
        pos, size = self.dir[name]
        return self.d[pos:pos + size]

    def patch(self, name):
        d = self.lump(name)
        if d is None: return None
        w, h, _, _ = struct.unpack_from('<hhhh', d, 0)
        im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        for x in range(w):
            p = struct.unpack_from('<i', d, 8 + 4 * x)[0]
            top = -1
            while d[p] != 0xFF:
                td = d[p]; ln = d[p + 1]
                top = td if td > top else top + td   # tall-patch rule
                for k in range(ln):
                    if 0 <= top + k < h:
                        im.putpixel((x, top + k), self.pal[d[p + 3 + k]] + (255,))
                p += ln + 4
        return im


def png(path):
    return Image.open(path).convert('RGBA')


# ---- layout --------------------------------------------------------------------------------------------------------
def tint(im, lo, hi):
    """a TEXTCOLO-style range (approximation): the glyph's brightness mapped from colour lo to colour hi"""
    out = im.copy(); px = out.load()
    mx = max((sum(px[x, y][:3]) for x in range(im.width) for y in range(im.height) if px[x, y][3]), default=1) or 1
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a:
                k = (r + g + b) / mx
                px[x, y] = tuple(int(lo[i] + (hi[i] - lo[i]) * k) for i in range(3)) + (a,)
    return out


def row(glyphs, scale, gap=2, hmax=None):
    """glyphs: list of RGBA; scaled (nearest) and set on one baseline (bottoms aligned)"""
    ims = [g.resize((max(1, int(g.width * scale)), max(1, int(g.height * scale))), Image.NEAREST) for g in glyphs]
    H = max(i.height for i in ims); W = sum(i.width for i in ims) + gap * (len(ims) - 1)
    out = Image.new('RGBA', (max(W, 1), H), (0, 0, 0, 0)); x = 0
    for i in ims:
        out.alpha_composite(i, (x, H - i.height)); x += i.width + gap
    return out


def wrap(glyphs, scale, width, gap=2):
    lines, cur, cw = [], [], 0
    for g in glyphs:
        w = int(g.width * scale) + gap
        if cur and cw + w > width:
            lines.append(cur); cur, cw = [], 0
        cur.append(g); cw += w
    if cur: lines.append(cur)
    return [row(l, scale, gap) for l in lines]


def sheet(title, notes, blocks, name):
    """blocks: list of (label, image)"""
    W = max([560] + [b.width + 24 for _, b in blocks])
    H = 30 + 14 * len(notes) + sum(b.height + 26 for _, b in blocks) + 8
    im = Image.new('RGBA', (W, H), BG); d = ImageDraw.Draw(im)
    d.text((12, 8), title, fill=(255, 220, 120)); y = 26
    for n in notes:
        d.text((12, y), n, fill=(150, 150, 160)); y += 14
    for label, b in blocks:
        y += 4; d.text((12, y), label, fill=INK); y += 14
        im.alpha_composite(b, (12, y)); y += b.height + 8
    im.save(os.path.join(HERE, name + '.png'), optimize=True)
    return im


def text_with(glyphs_by_code, s, scale, space=4):
    gl = []
    for ch in s:
        g = glyphs_by_code.get(ord(ch))
        if g is None: g = glyphs_by_code.get(ord(ch.upper()))   # the engine's fallback: no lower case -> capitals
        gl.append(g if g is not None else Image.new('RGBA', (space, 1), (0, 0, 0, 0)))
    return row(gl, scale, 1)


# ---- the sheets ----------------------------------------------------------------------------------------------------
def main():
    made = []
    # 1. RSSCFON (Score line)
    g, h = fon2(open(os.path.join(REPO, 'Score', 'RSSCFON.fon2'), 'rb').read())
    codes = sorted(g)
    made.append(sheet('RSSCFON.fon2 -- RSQ Score line font (Blue Shadow, via Dakka)',
        ['FON2, cell height %d, chars %d..%d (%d glyphs). Raw palette, then RSScore_Gold / White ramps (approx.)' % (h, codes[0], codes[-1], len(codes))],
        [('raw', wrap([g[c] for c in codes], 2, 900)[0]),
         *[('raw (cont.)', r) for r in wrap([g[c] for c in codes], 2, 900)[1:]],
         ('"Score: 128450" white label + gold number (approx.)',
          row([tint(text_with(g, 'Score: ', 1), (0x40, 0x40, 0x40), (0xFF, 0xFF, 0xFF)),
               tint(text_with(g, '128450', 1), (0x40, 0x30, 0x10), (0xFF, 0xD0, 0x30))], 3, 0))],
        'font_RSSCFON'))
    # 2. RSSCFN2 (breakdown / combo; also DOWN plate letters RSPC and Wheel WRSC digits)
    g2, h2 = fon2(open(os.path.join(REPO, 'Score', 'RSSCFN2.fon2'), 'rb').read())
    c2 = sorted(g2)
    fam = [('Base', (0xC0, 0xB0, 0x20), (0xFF, 0xD0, 0x30)), ('Efficiency', (0xC0, 0x90, 0x90), (0xFF, 0x80, 0x80)),
           ('Style', (0x90, 0xC0, 0x20), (0xB8, 0xFF, 0x30)), ('Daring', (0xC0, 0x60, 0x20), (0xFF, 0x80, 0x30)),
           ('Melee', (0x70, 0x90, 0xD0), (0xA0, 0xC8, 0xFF)), ('Counter', (0xB0, 0x70, 0xD0), (0xE0, 0xA0, 0xFF))]
    rows = []
    for nm, lo, hi in fam:
        rows.append(row([tint(text_with(g2, '+250', 1), lo, hi), Image.new('RGBA', (8, 1)),
                         tint(text_with(g2, nm.upper() if nm != 'Base' else 'BASE', 1), (0xC0, 0xC0, 0xC0), (0xFF, 0xFF, 0xFF))], 3, 0))
    made.append(sheet('RSSCFN2.fon2 -- RSQ Score breakdown / combo font (Jimmy, via Dakka)',
        ['FON2, cell height %d, chars %d..%d (%d glyphs, capitals only). Also DOWN plate letters (SlowMo RSPCnnn)' % (h2, c2[0], c2[-1], len(c2)),
         'and the Wheel web digits (WRSC048-057). Rows below: "+N  NAME" in each family colour (TEXTCOLO, approx.).'],
        [('raw', r) for r in wrap([g2[c] for c in c2], 3, 900)] + [('families', row(rows[:3], 1, 18)), ('', row(rows[3:], 1, 18))],
        'font_RSSCFN2'))
    # 3. JFO small + big
    js = os.path.join(REPO, 'GunCards', 'tools', 'card_art', 'jfo', 'small')
    jb = os.path.join(REPO, 'GunCards', 'tools', 'card_art', 'jfo', 'big')
    small = {int(f[5:8]): png(os.path.join(js, f)) for f in sorted(os.listdir(js))}
    big = {int(f[5:8]): png(os.path.join(jb, f)) for f in sorted(os.listdir(jb))}
    def crop(im):
        b = im.getbbox(); return im.crop((b[0], 0, b[2], im.height)) if b else im
    made.append(sheet('JFO -- JDUI font by Zedas, Blackmore1014 edit (GunCards/tools/card_art/jfo)',
        ['SmallFont 32 px cell, 41 glyphs: 0-9 A-Z + - / : = ; BigFont 64 px cell, digits 0-9 and +. Grey metal; tinted at run time.'],
        [('small (half size)', r) for r in wrap([crop(small[c]) for c in sorted(small)], 0.5, 900)] +
        [('big digits (half size)', row([crop(big[c]) for c in sorted(big)], 0.5, 2)),
         ('"REVIVE" / "x5" in small (half size)', row([text_with({k: crop(v) for k, v in small.items()}, 'REVIVE', 0.5, 16),
                                                   Image.new('RGBA', (24, 1)),
                                                   text_with({k: crop(v) for k, v in small.items()}, 'X5', 0.5, 16)], 1, 0))],
        'font_JFO'))
    # 4. Ermac
    ca = os.path.join(REPO, 'GunCards', 'tools', 'card_art')
    ed = [png(os.path.join(ca, 'digit_%s.png' % s)) for s in '0123456789'] + [png(os.path.join(ca, 'digit_%s.png' % s)) for s in ('plus', 'd', 'g', 'o')]
    words = [png(os.path.join(ca, f)) for f in ('ammo.png', 'magazine.png', 'chamber.png', 'reload.png')]
    made.append(sheet("Ermac's digits and words (Force Unleashed holo HUD; GunCards/tools/card_art)",
        ['12x12 pixel digits 0-9, +, d, g, o; the AMMO / MAGAZINE / CHAMBER / RELOAD words. x4 nearest.'],
        [('digits', row(ed, 4, 4)), ('words', row(words, 3, 12))], 'font_Ermac'))
    # 5. damnums Classic / Small
    cl = os.path.join(REPO, 'VisualRewards', 'tools', 'dn_art', 'classic')
    qc = [png(os.path.join(cl, 'QC11%s0.png' % c)) for c in 'ABCDEFGHIJ']
    qd = [png(os.path.join(cl, 'QD11%s0.png' % c)) for c in 'ABCDEFGHIJ']
    made.append(sheet("damnums' Doom Classic / Doom Small digits (Xaser; VisualRewards/tools/dn_art/classic)",
        ['QC11 14x16 and QD11 8x7, frames A-J = 0-9. x4 nearest (as gen_dn_art.py bakes the PCVR quality).'],
        [('Classic (QC11)', row(qc, 4, 4)), ('Small (QD11)', row(qd, 4, 4))], 'font_damnums'))
    # 6. DOWN seven-segment clock (downhud.zs lines 343-372 geometry, colours)
    def seven(ss, hh, blink=True, up=22.0):
        DX = [8.3, 10.6, 13.3, 15.6]; MASK = [0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F]
        dw, dh, th = 1.9, 3.6, 0.38
        W, H = int(up * 10), int(up * 5)
        im = Image.new('RGBA', (W, H), (0x17, 0x07, 0x08, 255)); d = ImageDraw.Draw(im)
        cx, cy = W / 2, H / 2
        lit = (0xFF, 0x2A, 0x1A)
        def box(x, y, w, h, a):
            c = tuple(int(lit[i] * a + (0x17, 0x07, 0x08)[i] * (1 - a)) for i in range(3))
            d.rectangle([cx + (x - 11.95) * up - w * up / 2, cy - y * up - h * up / 2, cx + (x - 11.95) * up + w * up / 2, cy - y * up + h * up / 2], fill=c)
        for di, dq in enumerate((ss // 10, ss % 10, hh // 10, hh % 10)):
            for s7 in range(7):
                x, y, w, h = DX[di], 0, th, th
                if s7 == 0: y, w = dh * .5, dw
                elif s7 == 1: x, y, h = DX[di] + dw * .5, dh * .25, dh * .5
                elif s7 == 2: x, y, h = DX[di] + dw * .5, -dh * .25, dh * .5
                elif s7 == 3: y, w = -dh * .5, dw
                elif s7 == 4: x, y, h = DX[di] - dw * .5, -dh * .25, dh * .5
                elif s7 == 5: x, y, h = DX[di] - dw * .5, dh * .25, dh * .5
                elif s7 == 6: w = dw
                box(x, y, w, h, 1.0 if MASK[dq] & (1 << s7) else 0.12)
        for q in (1, -1):
            box(11.95, q * -0.85, 0.45, 0.45, 1.0 if blink else 0.12)
        return im
    di = text_with(g2, 'DEATH IN:', 1)
    tab = Image.new('RGBA', (250, 170), (0x0B, 0x0B, 0x0D, 255)); tab.paste((0x17, 0x07, 0x08, 255), (6, 6, 244, 164))
    lab = tint(di, (0x60, 0x40, 0x40), (0xC9, 0x8A, 0x8A)); lab = lab.resize((lab.width * 16 // 7, 16), Image.NEAREST)
    tab.alpha_composite(lab, (16, 16)); tab.alpha_composite(seven(9, 0, True, 22.0).resize((228, 114)), (11, 42))
    made.append(sheet('DOWN seven-segment DEATH IN readout (SlowMo/zscript/rsqsm/downhud.zs 338-372)',
        ['Not a font: 7 RSPWHT quads per digit, lit #FF2A1A, unlit at 12% alpha, colon blinks every 17 tics.',
         'Drawn here from the code\'s own segment table; tab #0B0B0D rim / #170708 fill; label in RSSCFN2 tinted #C98A8A.'],
        [('the tab, 09:00', tab), ('digits 0-9 (SS:hh pairs 01:23, 45:67, 89:00; colon dim = blink off)',
          row([seven(1, 23), seven(45, 67, False), seven(89, 0)], 0.6, 8))], 'font_DOWN_sevenseg'))
    # 7. IWAD fonts
    w = Wad(WAD)
    stc = [(int(n[5:]), w.patch(n)) for n in sorted(w.dir) if n.startswith('STCFN') and n[5:].isdigit()]
    db, dbh = fon2(w.lump('DBIGFONT')) if w.lump('DBIGFONT') else ({}, 0)
    def nums(pfx, extra=()):
        return [w.patch('%s%d' % (pfx, i)) for i in range(10)] + [w.patch(e) for e in extra if w.patch(e)]
    blocks = [('STCFN (SmallFont / DoomFont), %d glyphs, x2' % len(stc), r) for r in wrap([p for _, p in stc], 2, 900)]
    blocks += [('STTNUM 0-9 - %% (HUDFONT_DOOM: status bar big red), x2', row(nums('STTNUM', ('STTMINUS', 'STTPRCNT')), 2, 2)),
               ('STYSNUM 0-9 (INDEXFONT_DOOM: yellow ammo table), x3', row(nums('STYSNUM'), 3, 3)),
               ('STGNUM 0-9 (grey arms numbers), x3', row(nums('STGNUM'), 3, 3)),
               ('WINUM 0-9 - %% : (intermission), x2', row(nums('WINUM', ('WIMINUS', 'WIPCNT', 'WICOLON')), 2, 2))]
    if db:
        blocks += [('DBIGFONT (FON2 in this IWAD, %d glyphs, cell %d), x1' % (len(db), dbh), r) for r in wrap([db[c] for c in sorted(db)], 1, 900)]
    made.append(sheet('Doom II IWAD fonts (%s)' % os.path.basename(WAD),
        ['Patches decoded through the IWAD PLAYPAL; native colours (the engine recolours SmallFont/BigFont by translation).'],
        blocks, 'font_IWAD'))
    # 8. BD22
    z = zipfile.ZipFile(BD)
    def bdp(n): return Image.open(io.BytesIO(z.read('graphics/HUDS/Font/%s.png' % n))).convert('RGBA')
    made.append(sheet('Brutal Doom 22 test6 HUD fonts (Fontdefs.txt; graphics/HUDS/Font)',
        ['DIGINUMBER = DIGNUM0S-9S + DIGMINUS; DIGIFONT_SMALL = DIGINUM0-9; DIGIFONT_LARGE = DIGLNUM0-9; AMMOFONT = IWAD STYSNUM.'],
        [('DIGINUMBER, x3', row([bdp('DIGNUM%dS' % i) for i in range(10)] + [bdp('DIGMINUS')], 3, 3)),
         ('DIGIFONT_SMALL, x4', row([bdp('DIGINUM%d' % i) for i in range(10)], 4, 4)),
         ('DIGIFONT_LARGE, x3', row([bdp('DIGLNUM%d' % i) for i in range(10)], 3, 3))], 'font_BD22'))
    # contact sheet
    W = 1200; thumbs = []
    for im in made:
        k = min(1.0, (W / 2 - 16) / im.width)
        thumbs.append(im.resize((int(im.width * k), int(im.height * k)), Image.LANCZOS))
    cols = [[], []]; hs = [0, 0]
    for t in thumbs:
        c = 0 if hs[0] <= hs[1] else 1; cols[c].append(t); hs[c] += t.height + 8
    cs = Image.new('RGBA', (W, max(hs) + 8), (8, 8, 10, 255))
    for c in range(2):
        y = 8
        for t in cols[c]:
            cs.alpha_composite(t, (8 + c * W // 2, y)); y += t.height + 8
    cs.convert('RGB').quantize(128).save(os.path.join(HERE, 'contact_sheet.png'), optimize=True)   # kept small
    print('wrote %d sheets + contact_sheet.png in %s' % (len(made), HERE))


if __name__ == '__main__':
    main()
