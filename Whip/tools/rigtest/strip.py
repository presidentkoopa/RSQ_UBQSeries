# TEST ONLY: python3 strip.py <shotdir> <out.png> f1 f2 ... (frame numbers) -> one strip
import sys; from PIL import Image
d, out, fr = sys.argv[1], sys.argv[2], [int(x) for x in sys.argv[3:]]
ims = [Image.open('%s/f%05d.ppm' % (d, f)) for f in fr]
w, h = ims[0].size
W = Image.new('RGB', (w * len(ims), h)); [W.paste(im, (k * w, 0)) for k, im in enumerate(ims)]
W.save(out)
