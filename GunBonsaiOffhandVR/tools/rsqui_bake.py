#!/usr/bin/env python3
"""rsqui_bake.py -- bakes the screens' fonts and graphics into the patch tree.

    python3 tools/rsqui_bake.py <fonts_ofl_dir>

Writes, under the worktree root (the parent of tools/):
  fonts/rsqui_pix/     Press Start 2P, labels: white-to-grey gradient, dark outline (tint with DTA_Color)
  fonts/rsqui_term/    VT323, body text: white, faux bold, thin dark outline (tint with DTA_Color)
  fonts/rsqui_orb/     Orbitron Bold, panel labels and card titles: gradient, outline (tint)
  fonts/rsqui_chrom/   Orbitron Black, the chrome-blue title: colour baked in, draw untranslated
  fonts/*/OFL.txt      each font's licence, beside it
  graphics/rsqui/RSQWHITE.png  a white swatch: every translucent panel is this, tinted

Every glyph is baked at BAKE x its logical size and the folder's font.inf says `Scale BAKE`, so
the engine measures text in logical units while the headset samples a 4x texture.
Rerunnable: every output is overwritten.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BAKE = 4  # bake factor (font.inf Scale)

ASCII = [chr(c) for c in range(33, 127)]
EXTRA = ['•', '·']           # bullet, middle dot
ARROWS = ['←', '→', '↑', '↓', '↵', '⬅', '➡']  # and GB's heavy arrows


def gradient(h, top, bottom, mid=None):
    """A list of h RGB tuples from top to bottom (optional (pos, rgb) stops)."""
    stops = [(0.0, top)] + (mid or []) + [(1.0, bottom)]
    out = []
    for y in range(h):
        t = y / max(1, h - 1)
        for i in range(len(stops) - 1):
            a, b = stops[i], stops[i + 1]
            if a[0] <= t <= b[0]:
                u = (t - a[0]) / max(1e-6, b[0] - a[0])
                out.append(tuple(int(a[1][k] + (b[1][k] - a[1][k]) * u) for k in range(3)))
                break
    return out


def draw_arrow(ch, w, h, asc, px):
    """Synthesised arrows for fonts that lack them: a 1-logical-pixel line drawing, white."""
    im = Image.new('L', (w, h), 0)
    d = ImageDraw.Draw(im)
    lw = max(1, px)
    cy = int(asc * 0.62)
    x0, x1 = px, w - px
    if ch in ('←', '⬅'):
        d.line([(x0, cy), (x1, cy)], fill=255, width=lw)
        d.line([(x0, cy), (x0 + 3 * px, cy - 3 * px)], fill=255, width=lw)
        d.line([(x0, cy), (x0 + 3 * px, cy + 3 * px)], fill=255, width=lw)
    elif ch in ('→', '➡'):
        d.line([(x0, cy), (x1, cy)], fill=255, width=lw)
        d.line([(x1, cy), (x1 - 3 * px, cy - 3 * px)], fill=255, width=lw)
        d.line([(x1, cy), (x1 - 3 * px, cy + 3 * px)], fill=255, width=lw)
    elif ch in ('↑', '↓'):
        cx = w // 2
        top, bot = int(asc * 0.2), int(asc * 0.95)
        d.line([(cx, top), (cx, bot)], fill=255, width=lw)
        tip = top if ch == '↑' else bot
        sgn = 1 if ch == '↑' else -1
        d.line([(cx, tip), (cx - 3 * px, tip + sgn * 3 * px)], fill=255, width=lw)
        d.line([(cx, tip), (cx + 3 * px, tip + sgn * 3 * px)], fill=255, width=lw)
    elif ch == '↵':
        top = int(asc * 0.25)
        d.line([(x1, top), (x1, cy)], fill=255, width=lw)
        d.line([(x0, cy), (x1, cy)], fill=255, width=lw)
        d.line([(x0, cy), (x0 + 3 * px, cy - 3 * px)], fill=255, width=lw)
        d.line([(x0, cy), (x0 + 3 * px, cy + 3 * px)], fill=255, width=lw)
    return im


def bake_font(name, ttf, size, chars, *, stroke, pad, grad, outline=(8, 6, 16), variation=None,
              synth=(), glow=None, licence=None, space=None, bold=0):
    """size = bake pixel size of the em. pad = per-side padding in bake px (multiple of BAKE/2)."""
    out = os.path.join(ROOT, 'fonts', name)
    os.makedirs(out, exist_ok=True)
    for f in os.listdir(out):
        if f.endswith('.png') or f == 'font.inf':
            os.remove(os.path.join(out, f))
    font = ImageFont.truetype(ttf, size)
    if variation:
        font.set_variation_by_axes(variation)
    asc, desc = font.getmetrics()
    H = asc + desc + 2 * pad
    colours = gradient(H, *grad) if isinstance(grad, tuple) else grad(H)
    for ch in chars + list(synth):
        cp = ord(ch)
        if ch in synth:
            adv = int(round(font.getlength('M')))
            w = adv + 2 * pad
            w = (w + BAKE - 1) // BAKE * BAKE
            mask = Image.new('L', (w, H), 0)
            mask.paste(draw_arrow(ch, adv, asc + desc, asc, BAKE), (pad, pad))
            if stroke:
                from PIL import ImageFilter
                omask = mask.filter(ImageFilter.MaxFilter(2 * stroke + 1))
            else:
                omask = mask
        else:
            adv = int(round(font.getlength(ch))) + bold
            # the engine keeps a glyph's advance as an int of logical units: round the cell up to
            # whole logical pixels or every letter loses up to 3/4 of one
            w = max(1, adv) + 2 * pad
            w = (w + BAKE - 1) // BAKE * BAKE
            mask = Image.new('L', (w, H), 0)
            ImageDraw.Draw(mask).text((pad, pad + asc), ch, font=font, fill=255, anchor='ls')
            if bold:
                # faux bold: the glyph smeared right by `bold` bake pixels
                from PIL import ImageChops
                base = mask.copy()
                for dx in range(1, bold + 1):
                    mask = ImageChops.lighter(mask, ImageChops.offset(base, dx, 0))
            omask = Image.new('L', (w, H), 0)
            if stroke:
                from PIL import ImageFilter
                omask = mask.filter(ImageFilter.MaxFilter(2 * stroke + 1))
            else:
                omask = mask
        im = Image.new('RGBA', (w, H), (0, 0, 0, 0))
        if glow:
            from PIL import ImageFilter
            g = omask.filter(ImageFilter.GaussianBlur(glow[0]))
            gl = Image.new('RGBA', (w, H), glow[1] + (0,))
            gl.putalpha(g.point(lambda v: int(v * glow[2])))
            im = Image.alpha_composite(im, gl)
        if stroke:
            ol = Image.new('RGBA', (w, H), outline + (0,))
            ol.putalpha(omask)
            im = Image.alpha_composite(im, ol)
        fill = Image.new('RGBA', (w, H))
        fp = fill.load()
        for y in range(H):
            c = colours[y]
            for x in range(w):
                fp[x, y] = c + (255,)
        fill.putalpha(mask)
        im = Image.alpha_composite(im, fill)
        if im.getbbox() is None and ch not in synth:
            continue
        im.save(os.path.join(out, '%04X.png' % cp))
    sw = space if space is not None else int(round(font.getlength(' ') / BAKE))
    with open(os.path.join(out, 'font.inf'), 'w') as f:
        f.write('Scale %d\n' % BAKE)
        f.write('Kerning %d\n' % (-(2 * pad) // BAKE))
        f.write('SpaceWidth %d\n' % sw)
        f.write('FontHeight %d\n' % ((asc + desc) // BAKE))
    if licence:
        with open(licence, 'rb') as a, open(os.path.join(out, 'OFL.txt'), 'wb') as b:
            b.write(a.read())
    print('%s: em %d px logical, height %d, asc %d desc %d (bake px)' % (name, size // BAKE, H, asc, desc))


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    ofl = sys.argv[1]
    chars = ASCII + EXTRA
    # Labels: Press Start 2P, the mockup's light-top gradient.
    bake_font('rsqui_pix', os.path.join(ofl, 'pressstart2p/PressStart2P-Regular.ttf'), 8 * BAKE,
              chars + ['←', '→'], stroke=BAKE, pad=BAKE,
              grad=((255, 255, 255), (150, 150, 160), [(0.5, (235, 235, 240))]),
              licence=os.path.join(ofl, 'pressstart2p/OFL.txt'))
    # Body: VT323, flat white (the tint is the colour), thin outline for the game behind it.
    bake_font('rsqui_term', os.path.join(ofl, 'vt323/VT323-Regular.ttf'), 16 * BAKE,
              chars, stroke=BAKE // 2 + 1, pad=BAKE, grad=((255, 255, 255), (225, 225, 230)),
              synth=ARROWS, licence=os.path.join(ofl, 'vt323/OFL.txt'), bold=BAKE // 2 + 1)
    # Panel labels and card titles: Orbitron Bold, the mockups' light-top gradient, dark outline.
    bake_font('rsqui_orb', os.path.join(ofl, 'orbitron/Orbitron[wght].ttf'), 16 * BAKE,
              [chr(c) for c in range(33, 127)] + ['\u2022'], stroke=BAKE, pad=BAKE, variation=[700],
              grad=((255, 255, 255), (150, 150, 165), [(0.45, (235, 235, 242)), (0.62, (185, 185, 198))]),
              outline=(10, 8, 20), licence=os.path.join(ofl, 'orbitron/OFL.txt'), space=7)
    # Title: Orbitron Black, chrome blue with a dark band, navy outline and a cyan glow.
    bake_font('rsqui_chrom', os.path.join(ofl, 'orbitron/Orbitron[wght].ttf'), 16 * BAKE,
              [chr(c) for c in range(33, 127)], stroke=BAKE + 2, pad=2 * BAKE,
              variation=[900],
              grad=((235, 248, 255), (150, 205, 240),
                    [(0.30, (165, 210, 240)), (0.47, (95, 150, 200)), (0.53, (60, 105, 160)),
                     (0.62, (120, 180, 225))]),
              outline=(14, 26, 52), glow=(BAKE * 1.5, (90, 190, 255), 0.55),
              licence=os.path.join(ofl, 'orbitron/OFL.txt'))
    os.makedirs(os.path.join(ROOT, 'graphics', 'rsqui'), exist_ok=True)
    # A white swatch for translucent fills: QZD draws Screen.Dim outside the HUD layer in VR (it
    # is a screen tint there), so every panel is this texture, tinted with DTA_Color.
    Image.new('RGBA', (8, 8), (255, 255, 255, 255)).save(os.path.join(ROOT, 'graphics', 'rsqui', 'RSQWHITE.png'))


if __name__ == '__main__':
    main()
