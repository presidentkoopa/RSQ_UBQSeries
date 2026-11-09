import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
SPEC = __import__('os').path.dirname(__import__('os').path.abspath(__file__))   # was /tmp/fx_beam
from variants import *
def grid(frames, pre, name, k0=-1, k1=None, cols=10, crop=None):
    k1 = k1 if k1 is not None else len(frames) - pre
    sel = [(k, frames[pre+k]) for k in range(k0, k1) if 0 <= pre+k < len(frames)]
    w, h = frames[0].size
    if crop: sel = [(k, f.crop(crop)) for k, f in sel]; w, h = crop[2]-crop[0], crop[3]-crop[1]
    rows = (len(sel)+cols-1)//cols
    g = Image.new('RGB', (cols*(w+4), rows*(h+4)), (90, 0, 90))
    for i, (k, f) in enumerate(sel):
        f = f.copy(); label(f, f't{k}')
        g.paste(f, ((i % cols)*(w+4), (i//cols)*(h+4)))
    g.save(f'{SPEC}/look/{name}.png'); return g.size
if __name__ == '__main__':
    which = sys.argv[1]
    if which == '1': f, p = V1(); print(grid(f, p, 'v1', -1, 16, 9, (150, 60, 450, 630)))
    if which == '2': f, p = V2(); print(grid(f, p, 'v2', -1, 18, 9, (150, 0, 450, 720)))
    if which == '3': f, p = V3(); print(grid(f, p, 'v3', -1, 19, 10, (150, 0, 450, 690)))
    if which == '4': f, p = V4(); print(grid(f, p, 'v4', -1, 48, 7, (0, 0, 720, 720)))
