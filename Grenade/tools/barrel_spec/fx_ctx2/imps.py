"""Imp front frames per tier folder (read-only). .lmp = Doom patch decoded with PLAYPAL."""
import glob,os,struct,numpy as np
from PIL import Image
IMP='/home/claude/rsq_ubqseries/Monsters/sprites/monsters/Imp/'
PAL=np.frombuffer(open('/tmp/eos/d2/data/PLAYPAL.pal','rb').read()[:768],np.uint8).reshape(256,3)
FRONT={'T01':'IMPGA1','T02':'IMPBA1','T03':'CIMPA1C1','T04':'TRO3A1','T05':'TRO4A1','T06':'IMPAA1','T07':'IMPFA1',
       'T08':'WARIA1','T09':'GIMPA1','T10':'PRIMA1C1','T11':'AGURA1C1','T12':'HELNA1D1'}
def patch(path):
    d=open(path,'rb').read(); w,h,lo,to=struct.unpack('<hhhh',d[:8])
    cols=struct.unpack(f'<{w}I',d[8:8+4*w]); a=np.zeros((h,w,4),np.uint8)
    for x,o in enumerate(cols):
        top=-1
        while True:
            t=d[o]
            if t==255: break
            top=t if t>top else top+t   # tall patches
            n=d[o+1]; px=d[o+3:o+3+n]
            for i,p in enumerate(px):
                y=top+i
                if 0<=y<h: a[y,x,:3]=PAL[p]; a[y,x,3]=255
            o+=n+4
    return Image.fromarray(a)
def front(tier,letter='A'):
    """front (rotation 1) frame of `letter`: name = sprite prefix + letter + '1' (+ mirrored pair), png preferred"""
    pre=FRONT[tier][:4]
    for ext in ('.png','.lmp'):
        c=sorted(glob.glob(f'{IMP}{tier}/{pre}{letter}1{ext}'))+sorted(glob.glob(f'{IMP}{tier}/{pre}{letter}1??{ext}'))
        if c: return Image.open(c[0]).convert('RGBA') if ext=='.png' else patch(c[0])
    raise FileNotFoundError(tier+letter)
if __name__=='__main__':
    from PIL import ImageDraw
    M=Image.new('RGB',(12*100,140),(40,40,48)); dr=ImageDraw.Draw(M)
    for i,t in enumerate(sorted(FRONT)):
        im=front(t); im=im.resize((im.width*1,im.height*1)); M.paste(im,(i*100+5,5),im); dr.text((i*100+5,125),f'{t} {im.size}',fill=(255,255,0))
    M=M.resize((M.width*2,M.height*2),Image.NEAREST); M.save('/tmp/fx_ctx2/look/imps.png')
