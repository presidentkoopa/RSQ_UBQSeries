# TEST ONLY: sheet.py <out.png> <run> [<run> ...] -> one row per run: idle, armed, push+2, push+6, pull+2, pull+6, grip, side
import sys, subprocess, os
from PIL import Image, ImageDraw
COLS = ['MARK_IDLE:0', 'MARK_ARMED:0', 'MARK_PUSH:2', 'MARK_PUSH:6', 'MARK_PULL:2', 'MARK_PULL:6', 'MARK_GRIP:0', 'MARK_SIDE:0']
NAMES = ['idle', 'Force up', 'push +2', 'push +6', 'pull +2', 'pull +6', 'grip', 'idle, hand turned']
here = os.path.dirname(os.path.abspath(__file__))
out, runs = sys.argv[1], sys.argv[2:]
rows = []
for r in runs:
    res = subprocess.run(['python3', '-I', os.path.join(here, 'frames.py'), os.path.join(here, 'out', r)] + COLS, capture_output=True, text=True).stdout.split('\n')
    rows.append([l.split()[-1] for l in res if l.strip()])
im0 = Image.open(rows[0][0]); w, h = im0.size; L = 18
S = Image.new('RGB', (w * len(COLS), (h + L) * len(rows) + L), (20, 20, 20))
d = ImageDraw.Draw(S)
for j, n in enumerate(NAMES): d.text((j * w + 4, 3), n, fill=(255, 255, 255))
for i, (r, fs) in enumerate(zip(runs, rows)):
    y = L + i * (h + L)
    d.text((4, y + 3), r, fill=(255, 220, 120))
    for j, f in enumerate(fs): S.paste(Image.open(f), (j * w, y + L))
S.save(out); print(out, S.size)
