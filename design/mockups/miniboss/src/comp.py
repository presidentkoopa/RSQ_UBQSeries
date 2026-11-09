"""Composition helpers: panels, glow text, chunky rings, mask outlines."""
import math, os
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops
import afonts as F

SANS = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
SANSB = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
def sans(n, bold=False): return ImageFont.truetype(SANSB if bold else SANS, n)

UPM = 32.0      # map units per metre (QuestZDoom's vr_vunits_per_meter default)
EYE = 960       # rig eye image, 90 x 90 degree symmetric FOV
def px_for(metres, dist_units):
    """on-screen pixels of something `metres` tall at dist (map units), near the view centre"""
    return (EYE / 2) * metres / (dist_units / UPM)
def deg(metres, dist_units): return math.degrees(2 * math.atan(metres / 2 / (dist_units / UPM)))

# Doom PLAYPAL colours used by the panels (index: rgb)
P = {i: F.pal(i) for i in range(256)}
GREEN, YELLOW, RED, WHITE = F.pal(112), F.pal(231), F.pal(176), F.pal(4)
GOLD = F.pal(161)   # (255,235,?) gold
ORANGE = F.pal(216)

def load(path, crop=None):
    im = Image.open(path).convert('RGBA')
    return im.crop(crop) if crop else im

def word(font, s, h, lo, hi, gap=1):
    """text in an RSQ font, nearest-scaled so the cap height is ~h px, tinted lo->hi (a TEXTCOLO-like range)"""
    base = F.text(font, s, 1, gap)
    k = max(1, round(h / base.height)) if h >= base.height else h / base.height
    if k >= 1: img = base.resize((base.width * k, base.height * k), Image.NEAREST)
    else: img = base.resize((max(1, int(base.width * k)), max(1, int(base.height * k))), Image.NEAREST)
    return F.tint(img, lo, hi) if lo is not None else img

def word_any(font, s, h, lo, hi, gap=1):
    """like word but allows non-integer scale (still nearest)"""
    base = F.text(font, s, 1, gap)
    k = h / base.height
    img = base.resize((max(1, round(base.width * k)), max(1, round(base.height * k))), Image.NEAREST)
    return F.tint(img, lo, hi) if lo is not None else img

def put(canvas, img, cx, cy, glowc=None, radius=6, strength=1.5, outline=2, anchor='c', alpha=1.0):
    if glowc is not None:
        img, pad = F.glow(img, glowc, radius, strength, outline)
    if alpha < 1:
        a = img.getchannel('A').point(lambda v: int(v * alpha)); img = img.copy(); img.putalpha(a)
    x = cx - img.width // 2 if anchor[0] in 'c' else cx
    if anchor == 'l': x = cx
    y = cy - img.height // 2
    canvas.alpha_composite(img, (int(x), int(y)))
    return img.size

def ring(r, col, thick=3, ticks=4, arc=1.0, px=3, rot=0.0, gapdeg=0, glow_r=8):
    """a chunky pixel ring (drawn at 1/px, nearest-upscaled), with tick marks; arc<1 draws a partial sweep"""
    R = int(r / px) + 4; S = 2 * R + 1
    im = Image.new('RGBA', (S, S), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    rr = r / px; t = max(1, round(thick / px))
    a0 = -90 + rot
    if arc >= 1: d.ellipse([R - rr, R - rr, R + rr, R + rr], outline=col + (255,), width=t)
    else: d.arc([R - rr, R - rr, R + rr, R + rr], a0, a0 + 360 * arc, fill=col + (255,), width=t)
    for k in range(ticks):
        a = math.radians(rot + k * 360 / ticks + 45 * (ticks == 4))
        x0, y0 = R + math.cos(a) * (rr - t * 2.5), R + math.sin(a) * (rr - t * 2.5)
        x1, y1 = R + math.cos(a) * (rr + t * 2.5), R + math.sin(a) * (rr + t * 2.5)
        d.line([x0, y0, x1, y1], fill=col + (255,), width=t + 1)
    big = im.resize((S * px, S * px), Image.NEAREST)
    out, pad = F.glow(big, col, glow_r, 1.3, 1)
    return out

def mask_from_pair(normal, painted, key=(255, 0, 255), tol=90):
    """exact silhouette: pixels that turned the stencil colour"""
    a = painted.convert('RGB'); px = a.load(); W, H = a.size
    m = Image.new('L', (W, H), 0); mp = m.load()
    for y in range(H):
        for x in range(W):
            r, g, b = px[x, y]
            if abs(r - key[0]) + abs(g - key[1]) + abs(b - key[2]) < tol: mp[x, y] = 255
    return m

def outline(mask, col, width=3, glow_r=10, strength=1.6, px=1):
    """glowing outline round a silhouette (pinball insert / lit target)"""
    m = mask
    dil = m
    for _ in range(width): dil = dil.filter(ImageFilter.MaxFilter(3))
    ring_ = ImageChops.subtract(dil, m)
    g = dil.filter(ImageFilter.GaussianBlur(glow_r)).point(lambda v: min(255, int(v * strength)))
    W, H = m.size
    out = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    out.alpha_composite(Image.merge('RGBA', (*Image.new('RGB', (W, H), col).split(), ImageChops.subtract(g, m))))
    out.alpha_composite(Image.merge('RGBA', (*Image.new('RGB', (W, H), col).split(), ring_)))
    return out

def tintfill(mask, col, alpha=0.35):
    W, H = mask.size
    return Image.merge('RGBA', (*Image.new('RGB', (W, H), col).split(), mask.point(lambda v: int(v * alpha))))

def zoom(im, box, k):
    c = im.crop(box); return c.resize((c.width * k, c.height * k), Image.NEAREST)

BG = (14, 14, 18)
def panel(num, title, scene, steps, notes, legend, out, step_labels=None, scene_w=1000):
    """scene: RGBA image; steps: list of RGBA images (shown at the right, same height each); notes: lines under the scene"""
    k = scene_w / scene.width
    sc = scene.resize((scene_w, int(scene.height * k)), Image.NEAREST if k >= 1 else Image.LANCZOS)
    sw = 0
    if steps:
        sh = min(220, (sc.height - 20 * (len(steps) - 1)) // len(steps))
        st = [s.resize((int(s.width * sh / s.height), sh), Image.NEAREST if sh >= s.height else Image.LANCZOS) for s in steps]
        sw = max(s.width for s in st) + 24
    Wd = 32 + sc.width + (sw + 8 if steps else 0) + 24
    head = 86
    Hd = head + sc.height + 26 + 22 * len(notes) + 30 + 20 * len(legend) + 20
    can = Image.new('RGBA', (Wd, Hd), BG + (255,)); d = ImageDraw.Draw(can)
    # title in the series' own font (DBIGFONT), gold, glow
    t = word_any(F.JFO, title, 26, (90, 70, 40), (255, 235, 180))
    n = word_any(F.JFOB, str(num), 40, (90, 70, 40), (255, 235, 180)) if num else None
    x = 32
    if n is not None: put(can, n, 32, 44, (255, 160, 60), 6, 0.8, 1, 'l'); x = 32 + n.width + 22
    put(can, t, x, 46, (255, 120, 40), 6, 0.6, 1, 'l')
    y0 = head
    # the scene, soft rounded corners (presentation frame only)
    m = Image.new('L', sc.size, 0); ImageDraw.Draw(m).rounded_rectangle([0, 0, sc.width - 1, sc.height - 1], 14, fill=255)
    can.paste(sc, (32, y0), m)
    if steps:
        xs = 32 + sc.width + 24; y = y0
        for i, s in enumerate(st):
            mm = Image.new('L', s.size, 0); ImageDraw.Draw(mm).rounded_rectangle([0, 0, s.width - 1, s.height - 1], 10, fill=255)
            can.paste(s, (xs, y), mm)
            if step_labels:
                lab = step_labels[i]
                f = sans(15, True)
                for ox, oy in ((1, 1), (2, 2), (-1, 1), (1, -1), (0, 2)): d.text((xs + 10 + ox, y + 8 + oy), lab, fill=(0, 0, 0), font=f)
                d.text((xs + 10, y + 8), lab, fill=(240, 240, 240), font=f)
            y += s.height + 20
    y = y0 + sc.height + 18
    for ln in notes:
        d.text((32, y), ln, fill=(225, 225, 230), font=sans(17)); y += 22
    y += 12
    for ln in legend:
        d.text((32, y), ln, fill=(150, 152, 165), font=sans(15)); y += 20
    can.convert('RGB').save(out, optimize=True)
    return can
