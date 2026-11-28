"""TEST ONLY: cmp2.py <pkA> <pkB> <Gun,...> <tag> [pose]: one run per gun, last frame, A left, B right."""
import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
import shots
from PIL import Image, ImageDraw
A, B, guns, tag = sys.argv[1], sys.argv[2], sys.argv[3].split(','), sys.argv[4]
POSE = sys.argv[5] if len(sys.argv) > 5 else '0.0 1.68 -0.40 20 -70 0'
w = h = 480
big = Image.new('RGB', (w * 2, h * len(guns))); d = ImageDraw.Draw(big)
for i, g in enumerate(guns):
    for j, pk in enumerate((A, B)):
        fs = shots.shoot('%s_%d_%d' % (tag, i, j), pk, 'qz_rhand "%s"; rsq_extra_weapons 1; give ammo; give %s; wait 2; use %s; wait 170' % (POSE, g, g), every=30, secs=400)
        if fs: big.paste(Image.open(fs[-1]), (j * w, i * h))
        if fs: __import__('shutil').rmtree(__import__('os').path.dirname(fs[-1]))	# frame dumps (.ppm) deleted once the frame is used
        d.text((j * w + 8, i * h + 8), '%s %s' % ('A' if j == 0 else 'B', g), fill=(255, 255, 0))
big.resize((w * 3 // 2, h * len(guns) * 3 // 4)).save(shots.SP + '/cmp2_%s.png' % tag); print('ok')
