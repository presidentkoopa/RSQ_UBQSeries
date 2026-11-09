import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from variants_v3 import *
from PIL import ImageDraw
KS = [0, 2, 3, 5, 6, 7, 8, 10, 12, 15, 18, 20, 22]
F = [('V3_zpillar_indoor_v3', 'indoor', (150, 0, 450, 750), 'V3 v3 INDOOR: ceiling found at 150 units -> column clipped there, splash cap spreads along the underside, sparks drop (Blue imp, tier 3)'),
     ('V3_zpillar_outdoor_v3', 'outdoor', (150, 0, 450, 870), 'V3 v3 OUTDOOR: open sky -> no cap, column tapers to a point and runs off the top, flame licks trail upward (Blue imp, tier 3)')]
rows = []
for name, where, crop, title in F:
    fr, pre = V3c(where)
    save_gif(fr, f'{OUT}/{name}_full.gif'); save_gif(fr, f'{OUT}/{name}_half.gif', half=True)
    print(name, len(fr), 'frames (tics), effect at', pre, 'size', fr[0].size)
    cells = []
    for k in KS:
        f = fr[pre+k].crop(crop); label(f, f'tic {k}'); cells.append(f)
    w = sum(c.width + 4 for c in cells); h = max(c.height for c in cells) + 24
    row = Image.new('RGB', (w, h), (40, 40, 48)); ImageDraw.Draw(row).text((6, 6), title, fill=(230, 230, 230))
    x = 0
    for c in cells: row.paste(c, (x, 24 + h - 24 - c.height)); x += c.width + 4
    rows.append(row)
W = max(r.width for r in rows); H = sum(r.height + 6 for r in rows)
out = Image.new('RGB', (W, H), (40, 40, 48)); y = 0
for r in rows: out.paste(r, (0, y)); y += r.height + 6
out.save(f'{OUT}/V3_v3_contact.png'); print('contact', out.size)
