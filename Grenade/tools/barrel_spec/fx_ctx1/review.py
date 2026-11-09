import sys, glob
from PIL import Image, ImageDraw
# usage: review.py NAME out.png tic tic ... [--crop x0,y0,x1,y1] [--cols N]
a = sys.argv[1:]; name, out = a[0], a[1]; crop = None; cols = 8; tics = []
i = 2
while i < len(a):
    if a[i] == '--crop': crop = tuple(int(v) for v in a[i + 1].split(',')); i += 2
    elif a[i] == '--cols': cols = int(a[i + 1]); i += 2
    else: tics.append(int(a[i])); i += 1
ims = []
for t in tics:
    p = f'/tmp/fx_ctx1/look/{name}_{t:+04d}.png'
    im = Image.open(p)
    if crop: im = im.crop(crop)
    ims.append((t, im))
w, h = ims[0][1].size; rows = (len(ims) + cols - 1) // cols
S = Image.new('RGB', (cols * w, rows * (h + 12)), (30, 30, 30)); d = ImageDraw.Draw(S)
for k, (t, im) in enumerate(ims):
    x = (k % cols) * w; y = (k // cols) * (h + 12)
    S.paste(im, (x, y + 12)); d.text((x + 2, y), f'{t:+d}', fill=(255, 220, 0))
S.save(out)
