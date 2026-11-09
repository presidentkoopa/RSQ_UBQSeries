import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from variants import *
from PIL import ImageDraw
# ---- tier ladder: V1 beam at key tics, 13 tiers
S = eos_scales(); keys = [0, 1, 3, 5, 8]
cw, ch = 104*U, 170*U
sheet = Image.new('RGB', (13*cw + 60, len(keys)*ch + 40), (8, 8, 10))
d = ImageDraw.Draw(sheet)
for n in range(1, 14):
    d.text((60 + (n-1)*cw + 6, 8), f'{n} {tier(n)[0]}', fill=(220, 220, 220))
    for r, k in enumerate(keys):
        cv = Canvas(Wu=100, Hu=170, floor=152)
        draw_eos_beam(cv, k, 0, n, S[k])
        sheet.paste(cv.frame(), (60 + (n-1)*cw, 40 + r*ch))
for r, k in enumerate(keys): d.text((6, 40 + r*ch + 8), f'tic {k}', fill=(220, 220, 220))
d.text((6, 40 + len(keys)*ch - 14), '', fill=(0, 0, 0))
sheet.save(f'{OUT}/beam_tiers_contact.png'); print('tiers', sheet.size)
# ---- key frames of each variant
rows = [('V1 EoS faithful (Green imp, tier 2)', V1, [0, 1, 2, 3, 4, 6, 8, 10], (140, 60, 460, 630)),
        ('V2 arcade (Brown imp, tier 13)', V2, [0, 1, 2, 3, 5, 7, 9, 12], (180, 0, 420, 720)),
        ('V3 Z-Fighter blue column + bursts (Blue imp, tier 3)', V3, [0, 1, 2, 3, 4, 6, 8, 10, 12], (150, 0, 450, 690)),
        ('V4 boss: ring converges -> skull pillar (Yellow caco, tier 5)', V4, [1, 4, 8, 11, 12, 14, 17, 20, 24, 33, 38], (90, 30, 630, 720))]
imgs = []
for title, fn, ks, crop in rows:
    fr, pre = fn(); cells = []
    for k in ks:
        f = fr[pre+k].crop(crop); label(f, f'tic {k}'); cells.append(f)
    w = sum(c.width + 4 for c in cells); h = cells[0].height + 24
    row = Image.new('RGB', (w, h), (40, 40, 48)); ImageDraw.Draw(row).text((6, 6), title, fill=(230, 230, 230))
    x = 0
    for c in cells: row.paste(c, (x, 24)); x += c.width + 4
    imgs.append(row)
W = max(i.width for i in imgs); H = sum(i.height + 6 for i in imgs)
out = Image.new('RGB', (W, H), (40, 40, 48)); y = 0
for i in imgs: out.paste(i, (0, y)); y += i.height + 6
out.save(f'{OUT}/beam_contact.png'); print('contact', out.size)
