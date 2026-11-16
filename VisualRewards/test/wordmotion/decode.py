# decode.py <run> <tag> (test only): read the probe's step squares (zscript.txt RenderOverlay) in each frame the rig drew; keep the
# last held frame of each step: the words' crop (and three full frames) in /home/claude/wm_scratch/crops/<tag>/sNN.png
import os, sys, numpy as np
from PIL import Image
run, tag = sys.argv[1], sys.argv[2]
d = '/home/claude/rig/work/runs/%s/frames' % run
best = {}
for f in sorted(os.listdir(d)):
    a = np.array(Image.open(os.path.join(d, f)).convert('RGB')).astype(int)
    bit = lambda b: a[520:525, 340 + 10 * b:345 + 10 * b].min(axis=2).mean() > 200
    st = sum(1 << b for b in range(7) if bit(b)); run_ = bit(7)
    if st and not run_: best[st] = f
print(run, 'steps', sorted(best))
C = '/home/claude/wm_scratch/crops/' + tag; os.makedirs(C, exist_ok=True)
for st, f in best.items():
    im = Image.open(os.path.join(d, f)).convert('RGB')
    im.crop((60, 300, 680, 440)).save(C + '/s%02d.png' % st)
    if st in (1, 5, 6): im.save(C + '/full_s%02d.png' % st)
