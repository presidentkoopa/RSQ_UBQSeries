"""Asset loading / cutting / recolour for set A. Reads sources read-only, caches cuts in /tmp/fx_ctx1/a/cuts."""
import glob, os, numpy as np
from PIL import Image
from scipy import ndimage as ndi
CFX='/home/claude/rsq_ubqseries/Monsters/sprites/combatfx/'
SH='/home/claude/rsq_ubqseries/design/assets/fx_sheets/'
EOS='/tmp/eosfr/'
def rgba(p): return Image.open(p).convert('RGBA')
def cfx(sub,prefix,letters):
    out=[]
    for L in letters:
        c=glob.glob(f'{CFX}{sub}/{prefix}{L}0.png') or glob.glob(f'{CFX}{sub}/{prefix}{L.lower()}0.png')
        out.append(rgba(c[0]))
    return out
def eos(k): return [rgba(p) for p in sorted(glob.glob(f'{EOS}{k}/*.png'))]
def clean(im,minpx=4,grow=1):
    """drop tiny isolated specks (stray neighbours)"""
    a=np.array(im); m=a[...,3]>0
    lab,n=ndi.label(ndi.binary_dilation(m,iterations=grow))
    if n<=1: return im
    sizes=ndi.sum(m,lab,range(1,n+1))
    keep=np.isin(lab,[i+1 for i,s in enumerate(sizes) if s>=minpx])
    a[~keep,3]=0; return Image.fromarray(a)
_ruf=None
def ruf():
    global _ruf
    if _ruf is None:
        a=np.array(rgba(SH+'fx_sheet_rufaswan_magma.png'))
        a[(a[...,:3]==255).all(-1),3]=0   # exact white = sheet background; sprite whites are 248,240,248
        _ruf=a
    return _ruf
def ruf_cells(y0,y1,xs,minpx=6):
    """cut frames: cells between x boundaries, each centred on a common-size canvas"""
    a=ruf(); fr=[]
    for x0,x1 in zip(xs[:-1],xs[1:]):
        c=Image.fromarray(a[y0:y1,x0:x1].copy()); c=clean(c,minpx,1); fr.append(c)
    return centre_pad(fr)
def centre_pad(fr):
    bbs=[f.getbbox() for f in fr]
    W=max(b[2]-b[0] for b in bbs if b); H=max(b[3]-b[1] for b in bbs if b)
    S=max(W,H)+2; out=[]
    for f,b in zip(fr,bbs):
        c=Image.new('RGBA',(S,S),(0,0,0,0))
        if b:
            g=f.crop(b); c.paste(g,((S-g.width)//2,(S-g.height)//2))
        out.append(c)
    return out
def rc_sheet(n,cell=None):
    im=rgba(SH+f'reactorcore_minipack/explosion ({n}).png'); c=im.width//4
    return [im.crop((x*c,y*c,x*c+c,y*c+c)) for y in range(4) for x in range(4)]
# ---------- recolour ----------
RAMPS={
 'fire':  [(0,(0,0,0)),(0.22,(90,8,0)),(0.45,(210,50,0)),(0.65,(255,130,10)),(0.82,(255,210,70)),(0.94,(255,250,190)),(1,(255,255,255))],
 'ember': [(0,(0,0,0)),(0.35,(120,15,0)),(0.65,(230,80,0)),(0.9,(255,180,40)),(1,(255,230,140))],
 'magma': [(0,(0,0,0)),(0.3,(140,0,40)),(0.55,(240,40,20)),(0.8,(255,150,20)),(1,(255,250,200))],
 'blue':  [(0,(0,0,0)),(0.3,(10,20,140)),(0.6,(40,140,255)),(0.85,(170,230,255)),(1,(255,255,255))],
 'smoke': [(0,(8,6,6)),(0.5,(48,42,40)),(1,(110,104,100))],
 'smokelt': [(0,(20,16,14)),(0.5,(80,72,68)),(1,(160,150,142))],
}
def ramp_lut(name):
    pts=RAMPS[name]; x=np.array([p[0] for p in pts]); c=np.array([p[1] for p in pts],float)
    t=np.linspace(0,1,256); return np.stack([np.interp(t,x,c[:,i]) for i in range(3)],-1)
def gmap(frames,ramp='fire',lo=None,hi=None,gamma=1.0,mode='lum'):
    """gradient map by brightness; lo/hi luminance stretch computed over the whole strip so frames stay consistent"""
    lut=ramp_lut(ramp)
    arrs=[np.array(f).astype(float) for f in frames]
    lum=[(0.3*a[...,0]+0.59*a[...,1]+0.11*a[...,2]) if mode=='lum' else a[...,:3].max(-1) for a in arrs]
    if lo is None or hi is None:
        allv=np.concatenate([l[a[...,3]>0] for l,a in zip(lum,arrs) if (a[...,3]>0).any()])
        lo=np.percentile(allv,1) if lo is None else lo; hi=np.percentile(allv,99.5) if hi is None else hi
    out=[]
    for l,a in zip(lum,arrs):
        t=np.clip((l-lo)/max(1,hi-lo),0,1)**gamma
        rgb=lut[(t*255).astype(int)]
        o=np.dstack([rgb,a[...,3]]).astype(np.uint8); out.append(Image.fromarray(o))
    return out
def tint(frames,mul):
    out=[]
    for f in frames:
        a=np.array(f).astype(float); a[...,:3]*=np.array(mul); out.append(Image.fromarray(np.clip(a,0,255).astype(np.uint8)))
    return out
def white(im):
    a=np.array(im).copy(); a[...,:3]=255; a[...,3]=np.where(a[...,3]>0,255,0); return Image.fromarray(a)

def circ(frames,pad=1):
    """round off frames whose ball was clipped flat by the sheet cell"""
    out=[]
    for f in frames:
        a=np.array(f).copy(); h,w=a.shape[:2]; yy,xx=np.mgrid[0:h,0:w]
        r=min(w,h)/2-pad; m=((xx-(w-1)/2)**2+(yy-(h-1)/2)**2)>r*r; a[m,3]=0; out.append(Image.fromarray(a))
    return out
