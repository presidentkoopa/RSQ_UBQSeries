#!/usr/bin/env python3
"""RSQ Wheel: the Colour by Gun look's art and colour table (owner's pick 2026-11-02: mock-ups A + B + C together).

Writes, into graphics/:
  WREPLATG.png  the card plate graded: lit at the top, shaded into the bottom (the ring's translation turns
                the light end into the gun's colour and the dark end cool, wr_q_shim.zs TransGrad)
  WRSHADE.png   the same grade as a multiply layer, for the status-bar stone (TEXTURES WRPLATG)
  WRECHIP.png   the slot number's box: bright rim, near-black fill
  WREHALO.png   a soft glow round a card's shape (drawn AddShaded, so the grey is the glow's strength)
  WREDISC.png   a soft round glow (the halo behind the ring)
  WRESPARK.png  a soft spark (the sweep round a card's edge)
  WRLKRB.png / WRLKCB.png  the series' lock-on mark: ring and centre (RSQ ShieldSaw's SSQRB0 / SSQCB0, its
                brightest frame, copied under the Wheel's own names)
and, between markers in zscript/wheel/wr_q_gunlook.zs, the colour table RSQ Gun Cards' cards show:
  SLOT_COL  per weapon slot 0..9, MEASURED from Gun Cards' panel art (GunCards/tools/card_art/ammo_bg<N>.png,
            N = Gun Cards' SLOT_STYLE, parsed from GunCards/zscript/rsqgc/card.zs): a filled panel's fill
            colour, an outlined panel's brightest saturated rim pixel (as the mock-up sampled it)
  PICK_COL  Gun Cards' single-colour choices (rsqgc_color 1..10), parsed from card.zs
Run from anywhere: python3 Wheel/tools/gen_glow_art.py"""
import os, re, shutil
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(HERE); REPO = os.path.dirname(W)
G = os.path.join(W, 'graphics')
GC = os.path.join(REPO, 'GunCards')


def rrect(w, h, x0, y0, x1, y1, r, fill, ss=4):
    im = Image.new('L', (w * ss, h * ss), 0)
    ImageDraw.Draw(im).rounded_rectangle((x0 * ss, y0 * ss, x1 * ss - 1, y1 * ss - 1), r * ss, fill=fill)
    return im.resize((w, h), Image.LANCZOS)


def grey_rgba(v):
    """a glow's strength v (L image) as grey on opaque black: drawn AddShaded, the engine takes red x alpha as the
    strength (an alpha texture), so alpha stays 255 and the grey alone says how strong"""
    a = np.asarray(v).astype(np.uint8)
    return Image.fromarray(np.dstack([a, a, a, np.full_like(a, 255)]), 'RGBA')


# ---- the graded plate: gen_ring_art.py's plate (128x80, radius 10, rim 3), fill and rim graded top -> bottom
def graded_plate(w=128, h=80, r=10, rim=3, fill_top=150, fill_bot=40, rim_top=245, rim_bot=150):
    t = np.linspace(0, 1, h)[:, None].repeat(w, 1)
    outer = np.asarray(rrect(w, h, 0, 0, w, h, r, 255)).astype(np.float32) / 255
    inner = np.asarray(rrect(w, h, rim, rim, w - rim, h - rim, max(1, r - rim), 255)).astype(np.float32) / 255
    fill = fill_top + (fill_bot - fill_top) * t
    rimv = rim_top + (rim_bot - rim_top) * t
    v = rimv * (outer - inner) + fill * inner
    a = (outer * 255).astype(np.uint8)
    v = np.clip(v / np.maximum(outer, 1e-3), 0, 255).astype(np.uint8)
    return Image.fromarray(np.dstack([v, v, v, a]), 'RGBA')


graded_plate().save(os.path.join(G, 'WREPLATG.png'))
# the multiply layer for the status bar's stone (WRPLATE is 55x21 of STBAR): white at the top, ~40% at the bottom
sh = np.linspace(255, 100, 21)[:, None].repeat(55, 1).astype(np.uint8)
Image.fromarray(np.dstack([sh, sh, sh, np.full_like(sh, 255)]), 'RGBA').save(os.path.join(G, 'WRSHADE.png'))

# ---- the slot box: rim bright, fill near black (the translation keeps dark dark)
chip = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
o = rrect(32, 32, 0, 0, 32, 32, 6, 255); i = rrect(32, 32, 3, 3, 29, 29, 4, 255)
oa, ia = np.asarray(o).astype(np.float32) / 255, np.asarray(i).astype(np.float32) / 255
v = np.clip((235 * (oa - ia) + 22 * ia) / np.maximum(oa, 1e-3), 0, 255).astype(np.uint8)
Image.fromarray(np.dstack([v, v, v, (oa * 255).astype(np.uint8)]), 'RGBA').save(os.path.join(G, 'WRECHIP.png'))

# ---- the hover halo: the card's shape (the inner 1/1.6 x 1/1.75 of the quad) blurred outward
HW, HH = 160, 120
cw, ch = HW / 1.6, HH / 1.75
m = rrect(HW, HH, (HW - cw) / 2, (HH - ch) / 2, (HW + cw) / 2, (HH + ch) / 2, 8, 255)
b = np.asarray(m.filter(ImageFilter.GaussianBlur(11))).astype(np.float32)
b = np.clip(b * 1.7, 0, 255)
b[:3, :] = b[-3:, :] = 0; b[:, :3] = b[:, -3:] = 0       # nothing at the quad's own edge
grey_rgba(Image.fromarray(b.astype(np.uint8))).save(os.path.join(G, 'WREHALO.png'))

# ---- the ring's halo: a soft round glow, nothing at the edge
yy, xx = np.mgrid[0:128, 0:128]; rr = np.hypot(xx - 63.5, yy - 63.5) / 63.5
disc = np.clip(np.exp(-(rr / 0.55) ** 2) * 1.15 - 0.03, 0, 1) * (rr < 1)
grey_rgba(Image.fromarray((disc * 255).astype(np.uint8))).save(os.path.join(G, 'WREDISC.png'))

# ---- the sweep's spark
yy, xx = np.mgrid[0:32, 0:32]; rr = np.hypot(xx - 15.5, yy - 15.5) / 15.5
sp = (np.exp(-(rr / 0.42) ** 2) * 0.8 + np.exp(-(rr / 0.15) ** 2) * 0.2) * (rr < 1)
grey_rgba(Image.fromarray((np.clip(sp, 0, 1) * 255).astype(np.uint8))).save(os.path.join(G, 'WRESPARK.png'))

# ---- the series' lock-on mark, from RSQ ShieldSaw (copied, never edited)
for f in 'B':
    shutil.copyfile(os.path.join(REPO, 'ShieldSaw', 'sprites', 'SSQR%s0.png' % f), os.path.join(G, 'WRLKR%s.png' % f))
    shutil.copyfile(os.path.join(REPO, 'ShieldSaw', 'sprites', 'SSQC%s0.png' % f), os.path.join(G, 'WRLKC%s.png' % f))

# ---- Gun Cards' colours, measured from its art and parsed from its code
card = open(os.path.join(GC, 'zscript', 'rsqgc', 'card.zs')).read()
slot_style = [int(x) for x in re.search(r'SLOT_STYLE\[\]\s*=\s*\{([^}]*)\}', card).group(1).split(',')]
pick_col = [x.strip() for x in re.search(r'PICK_COL\[\]\s*=\s*\{([^}]*)\}', card).group(1).split(',')]


def panel_colour(num):
    im = Image.open(os.path.join(GC, 'tools', 'card_art', 'ammo_bg%d.png' % num)).convert('RGB')
    if num < 10:
        return im.getpixel((150, 150))                       # a filled panel: its fill
    a = np.asarray(im).reshape(-1, 3).astype(int)
    s = a.max(1) - a.min(1) + a.sum(1) // 3
    return tuple(int(v) for v in a[s.argmax()])               # an outlined panel: its brightest saturated rim


slot_col = ['0x%02X%02X%02X' % panel_colour(n) for n in slot_style]
body = ('\t// generated by tools/gen_glow_art.py: Gun Cards\' SLOT_STYLE %s, each panel\'s colour measured from\n'
        '\t// GunCards/tools/card_art/ammo_bg<N>.png; PICK_COL as Gun Cards\' card.zs has it\n'
        '\tstatic const int SLOT_COL[] = { %s };\n'
        '\tstatic const int PICK_COL[] = { %s };') % (slot_style, ', '.join(slot_col), ', '.join(pick_col))
p = os.path.join(W, 'zscript', 'wheel', 'wr_q_gunlook.zs')
s = open(p).read()
a, rest = s.split('\t// >>> GUNCARDS COLOURS\n', 1)
_, z = rest.split('\t// <<< GUNCARDS COLOURS\n', 1)
open(p, 'w').write(a + '\t// >>> GUNCARDS COLOURS\n' + body + '\n\t// <<< GUNCARDS COLOURS\n' + z)
print('slot colours', dict(zip(range(10), slot_col)))
