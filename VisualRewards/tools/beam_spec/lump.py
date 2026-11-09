import struct,numpy as np
from PIL import Image
PAL=np.frombuffer(open('/tmp/eos/d2/data/PLAYPAL.pal','rb').read()[:768],np.uint8).reshape(256,3)
def load(p):
    d=open(p,'rb').read()
    if d[:8]==b'\x89PNG\r\n\x1a\n':
        from io import BytesIO; return Image.open(BytesIO(d)).convert('RGBA')
    w,h,lo,to=struct.unpack('<hhhh',d[:8])
    a=np.zeros((h,w,4),np.uint8)
    for x in range(w):
        off=struct.unpack('<I',d[8+4*x:12+4*x])[0]
        while d[off]!=255:
            top=d[off]; n=d[off+1]
            for i in range(n):
                y=top+i
                if y<h: a[y,x,:3]=PAL[d[off+3+i]]; a[y,x,3]=255
            off+=n+4
    return Image.fromarray(a)
