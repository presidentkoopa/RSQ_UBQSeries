import struct,numpy as np
from PIL import Image
PAL=np.frombuffer(open('/tmp/eos/d2/data/PLAYPAL.pal','rb').read()[:768],np.uint8).reshape(256,3)
def load(path):
    d=open(path,'rb').read()
    if d[:8]==b'\x89PNG\r\n\x1a\n': return Image.open(path).convert('RGBA')
    w,h,lo,to=struct.unpack('<HHhh',d[:8]); a=np.zeros((h,w,4),np.uint8)
    for x in range(w):
        p=struct.unpack('<I',d[8+4*x:12+4*x])[0]
        while d[p]!=255:
            y0=d[p]; n=d[p+1]; px=d[p+3:p+3+n]
            for i,c in enumerate(px):
                if y0+i<h: a[y0+i,x,:3]=PAL[c]; a[y0+i,x,3]=255
            p+=n+4
    return Image.fromarray(a)
if __name__=='__main__':
    import sys,os
    for f in sys.argv[1:]:
        load(f).save('/tmp/fx_rocket/caco/'+os.path.basename(f).replace('.lmp','.png'))
