import sys, os; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
import shots
from PIL import Image, ImageDraw
POSE = '0.0 1.68 -0.40 20 -70 0'
guns = sys.argv[2].split(',')
pk = {'v192': __import__('rig').B + '/BD22Q_192.pk3', 'vnow': sys.argv[1]}
out = {}
for tag, pk3 in pk.items():
    body = 'qz_rhand "%s"; rsq_extra_weapons 1; give ammo; ' % POSE
    for g in guns:
        body += 'give %s; wait 2; use %s; wait 150; echo B22SHOT %s; wait 25; ' % (g, g, g)
    fs = shots.shoot(tag + '_' + sys.argv[3], pk3, body, every=25, secs=1500)
    out[tag] = fs
# frames: one every 25; pick, for each gun, the frame just before the next gun's give (index from end)
n = len(guns)
w = h = 480
big = Image.new('RGB', (w * 2, h * n)); d = ImageDraw.Draw(big)
for j, tag in enumerate(('v192', 'vnow')):
    fs = out[tag]
    step = len(fs) / (n + 0.6)
    for i in range(n):
        k = min(len(fs) - 1, int(step * (i + 1) + step * 0.55))
        big.paste(Image.open(fs[k]), (j * w, i * h))
        d.text((j * w + 8, i * h + 8), '%s %s' % ('1.92' if j == 0 else 'NOW', guns[i]), fill=(255, 255, 0))
big.save(shots.SP + '/cmp_%s.png' % sys.argv[3]); print('saved', len(out['v192']), len(out['vnow']))
