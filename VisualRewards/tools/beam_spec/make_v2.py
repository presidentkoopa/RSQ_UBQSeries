import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from variants_v2 import *
from PIL import ImageDraw
F = [('V1_eos_v2', V1b, [0, 2, 4, 5, 6, 8, 10, 12, 14, 17, 20], (140, 60, 460, 630), 'V1 v2: EoS motion, imp delivered from inside the beam, rings drop and land (Green imp, tier 2)'),
     ('V2_arcade_v2', V2b, [0, 2, 3, 4, 5, 8, 10, 11, 12, 15, 19], (170, 0, 430, 720), 'V2 v2: arcade, more in-betweens (Brown imp, tier 13)'),
     ('V3_zpillar_v2', V3b, [0, 2, 3, 5, 7, 9, 12, 15, 18, 20, 22], (150, 0, 450, 750), 'V3 v2: blue column with crawling bands, licks, cap burst, pulsing ring, end pop (Blue imp, tier 3)'),
     ('V4_boss_v2', V4b, [3, 8, 12, 15, 18, 22, 27, 32, 45, 58, 64], (60, 30, 660, 720), 'V4 v2: spiralling ring converges -> longer skull pillar (Yellow caco, tier 5)')]
which = sys.argv[1:] or ['0', '1', '2', '3', 'c', 't']
rows = []
for i, (name, fn, ks, crop, title) in enumerate(F):
    if str(i) not in which and 'c' not in which: continue
    fr, pre = fn()
    if str(i) in which:
        save_gif(fr, f'{OUT}/{name}_full.gif'); save_gif(fr, f'{OUT}/{name}_half.gif', half=True)
        print(name, len(fr), 'frames (tics), effect at', pre)
    if 'c' in which:
        cells = []
        for k in ks:
            f = fr[pre+k].crop(crop); label(f, f'tic {k}'); cells.append(f)
        w = sum(c.width + 4 for c in cells); h = cells[0].height + 24
        row = Image.new('RGB', (w, h), (40, 40, 48)); ImageDraw.Draw(row).text((6, 6), title, fill=(230, 230, 230))
        x = 0
        for c in cells: row.paste(c, (x, 24)); x += c.width + 4
        rows.append(row)
if rows:
    W = max(r.width for r in rows); H = sum(r.height + 6 for r in rows)
    out = Image.new('RGB', (W, H), (40, 40, 48)); y = 0
    for r in rows: out.paste(r, (0, y)); y += r.height + 6
    out.save(f'{OUT}/beam_contact_v2.png'); print('contact', out.size)
if 't' in which:
    keys = [0, 3, 6, 9, 12, 16]
    cw, ch = 104*U, 190*U
    sheet = Image.new('RGB', (13*cw + 60, len(keys)*ch + 40), (8, 8, 10)); d = ImageDraw.Draw(sheet)
    for n in range(1, 14):
        fr, pre = V1b(n, mon=None)
        d.text((60 + (n-1)*cw + 6, 8), f'{n} {tier(n)[0]}', fill=(220, 220, 220))
        for r, k in enumerate(keys):
            f = fr[pre+k].crop((48*U, 0, 152*U, 190*U)); sheet.paste(f, (60 + (n-1)*cw, 40 + r*ch))
    for r, k in enumerate(keys): d.text((6, 40 + r*ch + 8), f'tic {k}', fill=(220, 220, 220))
    sheet.save(f'{OUT}/beam_tiers_contact_v2.png'); print('tiers', sheet.size)
