exec(open('/tmp/sotn/ext.py').read().split('if __name__')[0])
import numpy as np
LINES = ['CRITICAL!! GUARD MISS!!', 'CURSE STONE POISON -DOWN', '-UP STRENGTH INTELLIGENCE',
         'LUCKY DEFENCE OFFENCE', 'PROTECTION FROM FIRE DARK', 'HOLY ICE THUNDER PHYSICAL']

def glyphs_from_line(im, s):
    a = np.array(im)
    lum = a[:, :, :3].max(2) * (a[:, :, 3] > 0)
    bright = (lum > 110).any(0)
    runs = []; on = False
    for x, b in enumerate(bright):
        if b and not on: s0 = x; on = True
        if not b and on: runs.append((s0, x)); on = False
    if on: runs.append((s0, len(bright)))
    chars = [c for c in s if c != ' ']
    if len(runs) != len(chars):
        return None
    out = {}
    for (x0, x1), c in zip(runs, chars):
        g = im.crop((max(0, x0 - 1), 0, min(im.width, x1 + 1), im.height))
        out.setdefault(c, g)
    return out

SOTN = {}
for nm in ['white', 'cyan', 'green', 'gold', 'violet', 'red', 'silver', 'orange', 'lime']:
    gl = {}
    for k in range(1, 7):
        r = glyphs_from_line(WORDS[(nm, k, 0)], LINES[k - 1])
        if r:
            for c, g in r.items(): gl.setdefault(c, g)
    digs = DIG[nm]
    for i, g in enumerate(digs):
        gl['1234567890'[i]] = g
    SOTN[nm] = gl

def shade(g, f):
    a = np.array(g).astype(float)
    m = a[:, :, :3].max(2) > 110
    for ch in range(3):
        a[:, :, ch] = np.where(m, np.clip(a[:, :, ch] * f + (255 * (f - 1) if f > 1 else 0) * 0.25, 0, 255), a[:, :, ch])
    return Image.fromarray(a.astype('uint8'), 'RGBA')

def sotn_text(s, color='gold', f=1.0, sc=1):
    gl = SOTN[color]
    parts = []
    for c in s.upper():
        if c == ' ': parts.append(None); continue
        g = gl.get(c)
        if g is None: continue
        parts.append(shade(g, f) if f != 1.0 else g)
    w = sum((p.width - 1) if p else 3 for p in parts) + 1
    h = max((p.height for p in parts if p), default=8)
    im = Image.new('RGBA', (max(1, w), h), (0, 0, 0, 0)); x = 0
    for p in parts:
        if p is None: x += 3; continue
        im.alpha_composite(p, (x, 0)); x += p.width - 1
    if sc != 1: im = im.resize((im.width * sc, im.height * sc), Image.NEAREST)
    return im

if __name__ == '__main__':
    print({k: len(v) for k, v in SOTN.items()})
    print(sorted(SOTN['gold'].keys()))
    t = [sotn_text('KIOSK TIER 2', 'gold'), sotn_text('UNCOMMON 480', 'cyan'), sotn_text('LUCKY -UP RARE', 'violet'), sotn_text('1 LIFE', 'cyan')]
    W = max(i.width for i in t); H = sum(i.height + 3 for i in t)
    o = Image.new('RGBA', (W, H), (20, 20, 30, 255)); y = 0
    for i in t: o.alpha_composite(i, (0, y)); y += i.height + 3
    o.resize((W * 5, H * 5), Image.NEAREST).save('/tmp/sotn/test.png')
