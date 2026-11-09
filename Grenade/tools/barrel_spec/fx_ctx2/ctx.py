"""Context modifiers on the approved set-A barrel blasts (copies of /tmp/fx_agentA scripts in /tmp/fx_ctx2/lib, unmodified but for the sys.path line).

A 'plate' is an approved blast rendered exactly as set A renders it (same layers, debris, sparks, floor rings), but
over black and over white, so we recover its colour C (premultiplied) and its cover O (how much it hides what is
behind: smoke and debris hide, additive fire does not). The barrel layer is left out of the plate: scenes draw
their own barrels (idle / blink / gone) so a plate can be scaled without scaling the barrel.
A scene then composites plates anywhere on any canvas: out = back*(1-O) + C, after any per-shot modifier
(nearest scale, gradient map). Light pools are re-drawn per scene as flat bands (same shape as set A) in any colour.
"""
import sys, math, random, numpy as np
sys.path.insert(0,'/tmp/fx_ctx2/lib')
from PIL import Image
import fx, seqB, seqB_v3, assets as A
from fx import blit as _blit
T0=seqB.T0                       # 18: blast tic inside a plate
PBX,PFY=fx.BX,fx.FY              # plate anchor: barrel centre on the floor line (160, 262)
BG=np.array((0.035,0.03,0.04)); FLOORC=np.array((0.07,0.065,0.07)); LINEC=np.array((0.32,0.30,0.30))
SEQ={'snap':seqB_v3.snap,'heavy':seqB_v3.heavy,'pillar':seqB_v3.pillar}
_cache={}
def _render(Ls,Ss,Bk,bg,T):
    out=[]
    for t in range(T):
        c=np.zeros((fx.CH,fx.CW,3),np.float32); c[:]=bg
        for b in Bk: b.draw(c,t)
        for l in sorted(Ls,key=lambda l:l.z):
            if l.floor: continue
            r=l.at(t)
            if r: _blit(c,*r,l.add,l.gain,occ=fx.OCC)
        for s in Ss: s.draw(c,t)
        for l in Ls:
            if not l.floor: continue
            r=l.at(t)
            if r: _blit(c,*r,l.add,l.gain)
        out.append(c)
    return out
def plate(name):
    """-> (C list, O list, light fn); frame i = plate tic i, blast at tic T0"""
    if name in _cache: return _cache[name]
    Ls,Ss,lt,Bk=SEQ[name]()
    Ls=[l for l in Ls if l.name!='barrel']
    T=max([l.end() for l in Ls]+[s.end() for s in Ss+Bk])+2
    c0=_render(Ls,Ss,Bk,0.0,T); c1=_render(Ls,Ss,Bk,1.0,T)
    C=[a.copy() for a in c0]; O=[np.clip(1-(b-a),0,1).mean(-1) for a,b in zip(c0,c1)]
    _cache[name]=(C,O,lt); return _cache[name]
# ---------------- modifiers ----------------
def scale_plate(C,O,k):
    """nearest scale about the plate anchor; returns arrays + new anchor"""
    if abs(k-1)<1e-6: return C,O,(PBX,PFY)
    h,w=O.shape; W,H=max(1,round(w*k)),max(1,round(h*k))
    ys=np.minimum((np.arange(H)/k).astype(int),h-1); xs=np.minimum((np.arange(W)/k).astype(int),w-1)
    return C[ys][:,xs],O[ys][:,xs],(PBX*k,PFY*k)
def lum(C): return C[...,0]*.3+C[...,1]*.59+C[...,2]*.11
def ramp(*stops):
    x=np.array([s[0] for s in stops]); c=np.array([s[1] for s in stops],float)/255
    t=np.linspace(0,1,256); return np.stack([np.interp(t,x,c[:,i]) for i in range(3)],-1)
def hue_ramp(col,white_at=.93):
    """gradient map for a tint colour: black -> deep -> colour -> light -> pale (-> white from white_at, if <= 1).
    Fire yellows land on the light tint, oranges on the full colour."""
    col=np.array(col,float); deep=col*.35; light=col+(255-col)*.35; pale=col+(255-col)*.55
    st=[(0,(0,0,0)),(.15,tuple(deep*.6)),(.35,tuple(deep*1.4)),(.6,tuple(col)),(.78,tuple(col+(255-col)*.2)),(.9,tuple(light))]
    if white_at<=1: st+=[(white_at-.001,tuple(pale)),(white_at,(255,255,255)),(1,(255,255,255))]
    else: st+=[(1,tuple(pale))]
    return ramp(*st)
def gmap(C,lut,cover=None,smoke_keep=0.0,white=.93):
    """gradient-map a premultiplied plate by brightness. Flat steps (LUT quantised to 8 bands) so it stays pixel-flat.
    smoke_keep: share of the original colour kept on dark, unsaturated pixels (smoke) so smoke stays smoke-like."""
    L=np.clip(lum(C),0,1)
    q=np.floor(L*8)/8; q=np.where(L>=white,1.0,q)       # 8 flat steps; white-hot kept
    idx=(q*255).astype(int)
    out=lut[idx].astype(np.float32)
    if smoke_keep:
        sat=C.max(-1)-C.min(-1); m=((sat<.08)&(L<.5))[...,None]
        out=np.where(m,out*(1-smoke_keep)+C*smoke_keep,out)
    out[L<0.004]=0
    return out
# ---------------- scene canvas ----------------
class Scene:
    def __init__(s,W,H,FY):
        s.W,s.H,s.FY=W,H,FY
    def blank(s,bg=BG,floor=FLOORC,line=LINEC):
        c=np.zeros((s.H,s.W,3),np.float32); c[:]=bg; c[s.FY:]=floor; c[s.FY:s.FY+1]=np.maximum(c[s.FY:s.FY+1],line); return c
    def comp(s,c,C,O,anchor,x,y,solid=0.0):
        """put plate frame (C,O) with its anchor at (x,y). solid>0: bright fire also covers what is behind it
        (cover = max(O, lum*solid)), so on a lit wall it keeps its own colour instead of adding up to white."""
        if solid: O=np.maximum(O,np.clip(lum(C)*solid,0,1))
        ox=int(round(x-anchor[0])); oy=int(round(y-anchor[1]))
        h,w=O.shape
        x0,y0=max(0,ox),max(0,oy); x1,y1=min(s.W,ox+w),min(s.H,oy+h)
        if x1<=x0 or y1<=y0: return
        sc=C[y0-oy:y1-oy,x0-ox:x1-ox]; so=O[y0-oy:y1-oy,x0-ox:x1-ox][...,None]
        c[y0:y1,x0:x1]=c[y0:y1,x0:x1]*(1-so)+sc
    def pool(s,c,x,L,col=(1.0,.55,.2),k=1.0,y=None):
        """set-A light pool: three flat bands on the floor, additive"""
        if L<=0: return
        y=s.FY if y is None else y
        yy,xx=np.mgrid[y:s.H,0:s.W]; d=np.sqrt(((xx-x)/(110*k))**2+((yy-y)/(26*k))**2)
        band=np.select([d<0.35,d<0.7,d<1.0],[0.55,0.32,0.14],0)
        c[y:]+=band[...,None]*np.array(col)*min(L,1.0)
    def sprite(s,c,im,x,y,anchor='b',a=1.0,add=False):
        """RGBA PIL image, bottom-centre at (x,y)"""
        arr=np.asarray(im).astype(np.float32)/255.
        ox=int(round(x-im.width/2)); oy=int(round(y-im.height)) if anchor=='b' else int(round(y-im.height/2))
        x0,y0=max(0,ox),max(0,oy); x1,y1=min(s.W,ox+im.width),min(s.H,oy+im.height)
        if x1<=x0 or y1<=y0: return
        sub=arr[y0-oy:y1-oy,x0-ox:x1-ox]; al=sub[...,3:4]*a
        if add: c[y0:y1,x0:x1]+=sub[...,:3]*al
        else: c[y0:y1,x0:x1]=c[y0:y1,x0:x1]*(1-al)+sub[...,:3]*al
# barrel states (set A's barrel + EoS blink: lit/unlit x5 at 2 tics)
BAR=fx.barrel(); BAR_HOT=A.tint([BAR],(2.3,1.55,0.9))[0]
def barrel_img(t,tb,blink=10):
    """barrel image at tic t for a barrel that blows at tic tb (None once gone). Blink = last `blink` tics, 2 tics a state,
    starting lit (EoS: lit/unlit x5 at 2 tics for 10)."""
    if t>=tb: return None
    d=tb-t
    if d<=blink: return BAR_HOT if ((blink-d)//2)%2==0 else BAR
    return BAR
def ms_plate():
    """the other designer's Metal Slug mega blast as a plate (made by ms_plate.py) -> (C,O,light,lcol,T0,anchor)"""
    if 'ms' in _cache: return _cache['ms']
    z=np.load('/tmp/fx_ctx2/cache/ms_plate.npz')
    _cache['ms']=(z['C'],z['O'],z['light'],z['lcol'],int(z['T0']),(float(z['BX']),float(z['FY'])))
    return _cache['ms']
# ---------------- output ----------------
PAT_FULL=[30,30,30,30,30,30,20]; PAT_HALF=[60,60,60,60,60,50,50]
def to_img(c): return Image.fromarray((np.clip(c,0,1)*255).astype(np.uint8))
def save(frames,path,slow=1,hold=None):
    """frames: PIL images (1 per tic). 2x nearest. hold: per-frame repeat counts (slow-mo beats), same tic length each."""
    fr=[f.resize((f.width*2,f.height*2),Image.NEAREST).quantize(255,method=Image.MEDIANCUT,dither=Image.NONE) for f in frames]
    pat=PAT_FULL if slow==1 else PAT_HALF
    dur=[pat[i%7] for i in range(len(fr))]
    fr[0].save(path,save_all=True,append_images=fr[1:],duration=dur,loop=0,optimize=False,disposal=1)
