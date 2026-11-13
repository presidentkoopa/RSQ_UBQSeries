exec(open('/tmp/mock/mk.py').read())
exec(open('/tmp/sotn/sotnfont.py').read().split("\nif __name__ == '__main__':")[0])
import math

def tint_word(s, col, f=1.0, sc=1):
    im = sotn_text(s, 'white', 1.0, sc)
    a = np.array(im).astype(float)
    m = a[:, :, :3].max(2) > 110
    k = a[:, :, :3].max(2) / 255.0
    for ch in range(3):
        a[:, :, ch] = np.where(m, np.clip(col[ch] * k * f + (255 * max(0, f - 1)) * 0.35, 0, 255), a[:, :, ch])
    return Image.fromarray(a.astype('uint8'), 'RGBA')

BG = Image.open('/tmp/kbg.png').convert('RGBA')       # a real MAP01 frame from the rig (1080)
S = 540
BLUE = (70, 130, 255); PURPLE = (190, 100, 255); GOLDC = (255, 205, 40)
SH = [1.0, 1.25, 0.8, 1.15, 0.7, 1.3]                   # SOTN-style shade steps
NEUT = (205, 205, 215); DIM = (120, 120, 135)

offers = [  # sprite, effect, words, price
    ('SGN2A0.png', 'RECYCLING', 'AMMO OF EVERY KIND WHEN FIRED', 480),
    ('RIFLA0.png', 'FLAK', 'FLIERS BURST INTO EXPLOSIONS', 520),
    ('PRASA0.png', 'PROXIMITY', 'SHOTS DRIFT TO NEARBY ENEMIES', 560),
]
XS = [150, 270, 390]; GY = 222
SEL = 1
UPG_FX = ('SNIPER', '100% ACCURATE')

def ease(t): return 1 - (1 - t) ** 3

def frame(fi):
    lay = Image.new('RGBA', (S, S), (0, 0, 0, 0)); d = ImageDraw.Draw(lay)
    t = fi
    upgraded = t >= 44
    blend = 0 if t < 38 else min(1.0, (t - 38) / 6.0)
    # sign: KIOSK in SOTN gold, shimmering
    sf = SH[(t // 3) % len(SH)]
    d.rounded_rectangle((196, 14, 344, 52), 4, fill=(20, 16, 8, 230), outline=GOLDC)
    w = sotn_text('KIOSK', 'gold', sf, 2); lay.alpha_composite(w, (270 - w.width // 2, 18))
    w2 = tint_word('TIER 2 - UNCOMMON', BLUE, 1.0); lay.alpha_composite(w2, (270 - w2.width // 2, 40))
    # counter
    d.rectangle((82, 292, 461, 300), fill=(44, 40, 54, 255), outline=GOLDC)
    d.rectangle((82, 301, 461, 366), fill=(22, 20, 28, 255), outline=(150, 120, 30))
    for x in range(100, 461, 24): d.line((x, 304, x, 363), fill=(70, 60, 30))
    note = 'LUCKY: 1 LIFE = +1 RARITY  (ONE PER KIOSK)' if not upgraded else 'LUCKY USED THIS KIOSK'
    text(lay, SML, note, 271, 328, (255, 230, 150) if not upgraded else DIM, 1, 'c')
    # offers
    for i, (sp, eff, words, price) in enumerate(offers):
        x = XS[i]
        col = BLUE
        if i == SEL and blend > 0:
            col = tuple(int(BLUE[k] * (1 - blend) + PURPLE[k] * blend) for k in range(3))
        pulse = 0.75 + 0.25 * math.sin(t * 0.35 + i)
        bob = math.sin(t * 0.3 + i * 1.3) * 3
        # light column and glow
        glo = Image.new('RGBA', (S, S), (0, 0, 0, 0)); gd = ImageDraw.Draw(glo)
        gd.polygon([(x - 12, GY + 10), (x + 12, GY + 10), (x + 18, 292), (x - 18, 292)], fill=col + (int(70 * pulse),))
        gd.ellipse((x - 46, GY - 22 + bob, x + 46, GY + 14 + bob), fill=col + (int(160 * pulse),))
        if i == SEL and 38 <= t < 46:     # the rarity jump flash
            k2 = 1 - abs(t - 41) / 5.0
            gd.ellipse((x - 70, GY - 40, x + 70, GY + 30), fill=(255, 255, 255, int(150 * k2)))
        lay.alpha_composite(glo.filter(ImageFilter.GaussianBlur(9)))
        g = spr(sp); g = g.resize((int(g.width * 1.5), int(g.height * 1.5)), Image.NEAREST)
        lay.alpha_composite(g, (x - g.width // 2, int(GY - g.height // 2 + bob)))
        # price in SOTN gold digits, shimmering out of step per offer
        pf = SH[((t // 3) + i * 2) % len(SH)]
        pw = sotn_text('%d' % price, 'gold', pf, 2)
        gw = tint_word('G', GOLDC, pf, 2)
        tw_ = pw.width + gw.width + 4
        d.rounded_rectangle((x - tw_ // 2 - 5, 242, x + tw_ // 2 + 5, 262), 3, fill=(20, 16, 8, 255), outline=col)
        lay.alpha_composite(pw, (x - tw_ // 2, 245)); lay.alpha_composite(gw, (x - tw_ // 2 + pw.width + 4, 245))
        rname = 'RARE' if (i == SEL and upgraded) else 'UNCOMMON'
        rw = tint_word(rname, col, 1.0, 1); lay.alpha_composite(rw, (x - rw.width // 2, 266))
        ename = UPG_FX[0] if (i == SEL and upgraded) else eff
        text(lay, SML, ename, x, 278, NEUT, 1, 'c')

    # pointing laser at the selected offer
    if t >= 10:
        d.line((S - 60, S, XS[SEL] + 6, GY), fill=(255, 60, 60), width=1)
    # the compare card pops in (SOTN pop: big, small, settle), neutral text only
    if t >= 14:
        p = min(1.0, (t - 14) / 7.0)
        scl = 0.35 + 0.65 * ease(p) + (0.08 * math.sin(p * math.pi) if p < 1 else 0)
        card = Image.new('RGBA', (232, 112), (0, 0, 0, 0)); cd = ImageDraw.Draw(card)
        ccol = PURPLE if upgraded else BLUE
        cd.rounded_rectangle((0, 0, 231, 111), 4, fill=(14, 12, 22, 240), outline=ccol)
        cd.rectangle((4, 4, 227, 18), fill=tuple(c // 3 for c in ccol) + (255,))
        text(card, BIG, 'RIFLE', 8, 5, WHITE, 1)
        rw = tint_word('RARE' if upgraded else 'UNCOMMON', ccol, 1.2); card.alpha_composite(rw, (224 - rw.width, 7))
        fx = UPG_FX if upgraded else (offers[1][1], offers[1][2])
        text(card, SML, fx[0], 8, 23, WHITE, 1)
        text(card, SML, fx[1], 8, 32, NEUT, 1)
        text(card, SML, 'THIS', 150, 43, WHITE, 1, 'c'); text(card, SML, 'YOURS', 200, 43, DIM, 1, 'c')
        rows = [('DAMAGE', '19', '16'), ('RATE', '9.8/S', '9.1/S'), ('ACCURACY', '72%' if not upgraded else '100%', '61%'),
                ('MAGAZINE', '34', '31'), ('UPGRADES', '0/3' if not upgraded else '0/4', '2/2'), ('CONDITION', '100%', '41%')]
        nshow = min(len(rows), max(0, (t - 18) // 2)) if t < 44 else len(rows)
        for j in range(nshow):
            lab, a, b = rows[j]; ry = 52 + j * 8
            text(card, SML, lab, 8, ry, NEUT, 1)
            text(card, SML, a, 150, ry, WHITE, 1, 'c')
            text(card, SML, b, 200, ry, DIM, 1, 'c')
        cd.line((6, 101, 225, 101), fill=(70, 60, 40))
        if not upgraded:
            hl = 30 <= t < 38 and (t // 2) % 2 == 0
            text(card, SML, 'LUCKY: SPEND 1 LIFE FOR +1 RARITY', 8, 103, (140, 255, 255) if hl else (150, 200, 210), 1)
        else:
            text(card, SML, '520 G   HOLD GRIP TO BUY', 8, 103, GOLDC, 1)
        cw, ch = int(232 * scl), int(112 * scl)
        card = card.resize((max(1, cw), max(1, ch)), Image.NEAREST)
        lay.alpha_composite(card, (270 - cw // 2 + 0, 150 - ch // 2 - 4))

    # the life pip flies from the wrist to the offer
    pip = Image.open('/home/claude/rsq_ubqseries/Score/graphics/HUD_LIF1.png').convert('RGBA').resize((14, 14), Image.NEAREST)
    lives = 2 if t < 38 else 1
    if 32 <= t < 38:
        q = ease((t - 32) / 6.0)
        px = int(60 + (XS[SEL] - 60) * q); py = int(470 + (GY - 470) * q - 60 * math.sin(q * math.pi))
        lay.alpha_composite(pip, (px - 7, py - 7))
    # SOTN word pops over the offer when it jumps: LUCKY, then -UP
    if 38 <= t < 60:
        k = t - 38
        word = 'LUCKY' if k < 10 else 'RARE'
        f2 = SH[(t // 2) % len(SH)]
        wim = sotn_text(word, 'violet', f2, 2) if word == 'RARE' else sotn_text(word, 'gold', f2, 2)
        s2 = 1.6 - 0.6 * ease(min(1.0, (k % 10) / 4.0))
        wim = wim.resize((int(wim.width * s2), int(wim.height * s2)), Image.NEAREST)
        a = 1.0 if k < 18 else max(0.0, 1 - (k - 18) / 4.0)
        if a < 1: wim.putalpha(wim.split()[3].point(lambda v: int(v * a)))
        lay.alpha_composite(wim, (XS[SEL] - wim.width // 2, GY - 52 - k))

    # the off-hand wrist: lives and gold, neutral text, lives as Score's own pips
    d.rounded_rectangle((10, 440, 130, 520), 4, fill=(14, 12, 22, 235), outline=(110, 110, 125))
    text(lay, SML, 'LIVES', 18, 448, NEUT, 1)
    for k in range(lives): lay.alpha_composite(pip, (60 + k * 16, 445))
    text(lay, SML, 'GOLD', 18, 470, NEUT, 1)
    gw2 = sotn_text('1240', 'gold', SH[(t // 3) % len(SH)], 2); lay.alpha_composite(gw2, (60, 465))
    text(lay, SML, 'IN HAND: RIFLE', 18, 490, NEUT, 1)
    text(lay, SML, 'CONDITION 41%', 18, 502, NEUT, 1)

    out = BG.copy()
    out.alpha_composite(lay.resize((1080, 1080), Image.NEAREST))
    out = out.crop((0, 0, 1080, 1080)).crop((0, 0, 1080, 1060))
    return out.crop((0, 0, 1080, 1060)).resize((810, 795), Image.LANCZOS)

frames = [frame(i) for i in range(72)]
pal = [f.convert('RGB').quantize(colors=160, method=Image.MEDIANCUT) for f in frames]
pal[0].save('/mnt/user-data/outputs/datacard_kiosk/kiosk_lucky_anim.gif', save_all=True, append_images=pal[1:], duration=70, loop=0)
frames[60].convert('RGB').save('/mnt/user-data/outputs/datacard_kiosk/kiosk_lucky_still.png')
print('ok')
