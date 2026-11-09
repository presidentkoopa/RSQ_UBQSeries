# v2 compositor: everything centred on the barrel, pixel sources only, EoS barrel-death structure.
# Reuses constants/ramps/background/blit/save_gif from fx.py (unchanged).
import os,glob,math,random
import numpy as np
from PIL import Image,ImageDraw
from fx import (CF,CW,CH,FLOOR,BX,U,BH,R_SHOCK,R_DUST,R_SOOT,R_DIRTY,R_EMBER,R_NEON,R_GOLD,R_HOT,ramp,lum,
                background,blit,save_gif,BARREL)
def Z(z): return FLOOR-z*U          # map units above floor -> canvas y
MAINZ=24                            # EoS: A_SpawnItemEx("Explosm",0,0,24)
_cache={}
def _files(key):
    if os.path.isdir(f'/tmp/eosfr/{key}'): return sorted(glob.glob(f'/tmp/eosfr/{key}/*.png'))
    if os.path.isdir(f'/tmp/fx_agentB/cut/{key}'): return sorted(glob.glob(f'/tmp/fx_agentB/cut/{key}/*.png'))
    return sorted(glob.glob(f'{CF}/{key}'),key=lambda p:os.path.basename(p)[:6].upper())
def centre(im,mode='bbox'):
    """re-centre a frame on its art: 'bbox' = crop to the alpha bounding box (bbox centre becomes image centre);
    'cent' = pad so the alpha-weighted centroid sits at the image centre."""
    a=np.asarray(im); al=a[...,3]
    ys,xs=np.nonzero(al>8)
    if len(xs)==0: return im
    if mode=='bbox':
        return im.crop((xs.min(),ys.min(),xs.max()+1,ys.max()+1))
    w=al.astype(float); cy=(w.sum(1)*np.arange(al.shape[0])).sum()/w.sum(); cx=(w.sum(0)*np.arange(al.shape[1])).sum()/w.sum()
    im=im.crop((xs.min(),ys.min(),xs.max()+1,ys.max()+1)); cx-=xs.min(); cy-=ys.min()
    W=int(2*max(cx,im.width-cx)+1); H=int(2*max(cy,im.height-cy)+1)
    out=Image.new('RGBA',(W,H)); out.paste(im,(int(round(W/2-cx)),int(round(H/2-cy)))); return out
def strip(key,mode='cent'):
    k=(key,mode)
    if k not in _cache:
        fs=_files(key); assert fs,key
        fr=[Image.open(p).convert('RGBA') for p in fs]
        _cache[k]=[centre(f,mode) if mode else f for f in fr]
    return _cache[k]
def pick(key,idx,mode='cent'): s=strip(key,mode); return [s[i] for i in idx]
def solid(col):  # single-colour silhouette ramp
    return np.tile(np.array(col,float),(256,1))
class L:
    """sprite layer. pos is canvas (x,y). All scaling is nearest-neighbour.
    presq: per-tic list of (sx,sy) applied BEFORE roll (GZDoom A_SetScale then roll)."""
    def __init__(s,frames,tics,start=0,pos=(BX,FLOOR),size=None,scale=None,grow=0.0,rot=0,flip=False,squash=1.0,
                 ramp=None,cool=0.0,bright=1.0,add=True,alpha=1.0,fade=None,fadein=0,vel=(0,0),acc=(0,0),spin=0,
                 sil=0,silcol=(255,255,255),anchor='c',ease=1.0,gain=1.0,xs=1.0,clip=None,presq=None,alist=None):
        s.fr=frames; s.tl=tics if isinstance(tics,list) else [tics]*len(frames)
        assert len(s.tl)==len(s.fr),(len(s.tl),len(s.fr))
        s.start=start; s.pos=pos; s.grow=grow; s.rot=rot; s.flip=flip; s.sq=squash; s.ramp=ramp; s.cool=cool
        s.bright=bright; s.add=add; s.alpha=alpha; s.fade=fade; s.fadein=fadein; s.spin=spin
        s.sil=sil; s.silcol=np.array(silcol,float); s.anchor=anchor; s.ease=ease; s.gain=gain; s.xs=xs
        s.clip=(squash>=.5) if clip is None else clip; s.presq=presq; s.alist=alist
        mx=max(max(f.size) for f in frames)
        s.k0=(scale*U) if scale else (size*U/mx if size else U)
        s.vel=(vel[0]*U,vel[1]*U); s.acc=(acc[0]*U,acc[1]*U)
        s.len=sum(s.tl)
    def frame_at(s,t):
        t-=s.start
        if t<0 or t>=s.len: return None
        acc=0
        for i,d in enumerate(s.tl):
            if t<acc+d: return i,t
            acc+=d
    def render(s,t):
        r=s.frame_at(t)
        if r is None: return None
        i,tt=r; k=tt/max(1,s.len-1)
        im=s.fr[i]
        sc=s.k0*(1+s.grow*(1-(1-k)**s.ease if s.ease!=1 else k))
        sx=sy=sc
        if s.presq: px,py=s.presq[min(tt,len(s.presq)-1)]; sx*=px; sy*=py
        im=im.resize((max(1,round(im.width*sx)),max(1,round(im.height*sy))),Image.NEAREST)
        if s.flip: im=im.transpose(Image.FLIP_LEFT_RIGHT)
        rot=s.rot+s.spin*tt
        if rot%360: im=im.rotate(rot,expand=True,resample=Image.NEAREST)
        if s.sq!=1 or s.xs!=1: im=im.resize((max(1,round(im.width*s.xs)),max(1,round(im.height*s.sq))),Image.NEAREST)
        a=np.asarray(im).astype(float)
        rgb=a[...,:3]; al=(a[...,3]>127).astype(float)   # hard 1-bit alpha: no soft edges
        if s.sil and s.sil[0]<=tt<s.sil[1]: rgb=np.broadcast_to(s.silcol,rgb.shape).copy()
        elif s.ramp is not None:
            p=np.clip(lum(a)*s.gain*(1-s.cool*k),0,1); rgb=s.ramp[(p*255).astype(int)]
        m=s.alpha*s.bright
        if s.alist: m*=s.alist[min(tt,len(s.alist)-1)]
        if s.fade is not None and k>s.fade: m*=max(0,1-(k-s.fade)/(1-s.fade+1e-9))
        if s.fadein and tt<s.fadein: m*=(tt+1)/(s.fadein+1)
        x=s.pos[0]+s.vel[0]*tt+0.5*s.acc[0]*tt*tt; y=s.pos[1]+s.vel[1]*tt+0.5*s.acc[1]*tt*tt
        h,w=al.shape
        ox=int(round(x-w/2)); oy=int(round(y-(h if s.anchor=='b' else h/2)))
        if s.clip:
            cut=int(FLOOR+1-oy)
            if cut<h: al=al.copy(); al[max(0,cut):]=0
        return rgb,al,m,ox,oy
def main_blast(frames,dtic,rot,size,z=MAINZ,silcol=(255,255,255),**kw):
    """EoS Explosm: frame 0 for 1 tic, the same frame as a 2-tic solid silhouette, then the rest."""
    fr=[frames[0],frames[0]]+list(frames[1:]); tl=[1,2]+(dtic if isinstance(dtic,list) else [dtic]*(len(frames)-1))
    return L(fr,tl,start=0,pos=(BX,Z(z)),size=size,rot=rot,sil=(1,3),silcol=silcol,**kw)
def pops(rng,ramp_,size=34,z=4,start=0,gain=1.2):
    """EoS ExplosionPop x3 on the same tic: flat streak, roll = random angle (+90..130 each), scale (1,.4)->(.8,.55)->(.7,.8),
    alpha .8 fading. Art: Rufaswan streak flare (cut/r276 #15) stood upright."""
    st=strip('r276')[15].rotate(90,expand=True)
    a=rng.randint(0,359); out=[]
    for i in range(3):
        out.append(L([st],[3],start=start,pos=(BX,Z(z)),size=size,rot=a,presq=[(1,.4),(.8,.55),(.7,.8)],
                     alist=[.8,.6,.3],ramp=ramp_,gain=gain,clip=True))
        a+=rng.randint(90,130)
    return out
class Embers:
    """EoS BarrelFire: 2 per tic for 7 tics, spawn x within +-26 units (balanced in pairs), z 16..32, velz 6..12 up,
    gravity; art = RS Combat FX pixel ember bits RSS0A0-RSS0D0, 2-3 tics a frame."""
    def __init__(s,start,seed=1,ramp_=None,gain=1.0,scale=1.25,grav=1.0,n_tics=7):
        rng=random.Random(seed); s.items=[]
        fr=strip('sparks/RSS0[A-D]0.png',None)
        for t in range(n_tics):
            r=rng.uniform(4,26)
            for sgn in (-1,1):   # two per tic, one each side: scattered but centred on the barrel
                x=sgn*rng.uniform(r*.6,r); z=rng.uniform(16,32); vz=rng.uniform(6,12)
                tl=[rng.choice([2,3]) for _ in fr]; rot=rng.choice([0,90,180,270])
                s.items.append((start+t,x,z,vz,L(fr,tl,start=0,scale=scale,rot=rot,ramp=ramp_,gain=gain,clip=False,fade=.6)))
        s.grav=grav; s.start=start; s.len=max(st+it.len for st,_,_,_,it in s.items)-start
    def draw(s,c,t):
        for st,x,z,vz,it in s.items:
            tt=t-st
            if tt<0 or tt>=it.len: continue
            zz=z+vz*tt-0.5*s.grav*tt*tt
            if zz<0: continue
            it.pos=(BX+x*U,Z(zz)); r=it.render(tt)
            if r: blit(c,*r,True)
class Particles:
    """engine particles drawn as hard pixel squares (A_SpawnParticle style); symmetric launch angles around straight up."""
    def __init__(s,n,start,z,speed=(2,5),life=(6,12),g=0.35,col=((255,240,180),(255,120,20)),sz=2,seed=1,spread=180,
                 add=True,drag=0.95,bounce=0.3,szr=(0,0)):
        rnd=random.Random(seed); s.start=start; s.col=col; s.add=add; s.paths=[]
        for i in range(n):
            sgn=1 if i%2 else -1
            ang=math.radians(sgn*rnd.uniform(0,spread/2)-90); v=rnd.uniform(*speed)*U
            x=BX+sgn*rnd.uniform(0,3)*U; y=Z(z)+rnd.uniform(-3,3)*U; vx=math.cos(ang)*v; vy=math.sin(ang)*v
            life_=rnd.randint(*life); d=rnd.randint(0,2); size=sz+rnd.randint(*szr); path=[]
            for t in range(life_):
                path.append((x,y)); x+=vx; y+=vy; vy+=g*U; vx*=drag; vy*=drag
                if y>FLOOR-size+1: y=FLOOR-size+1; vy=-vy*bounce; vx*=0.6
            s.paths.append((d,path,size))
        s.len=max(d+len(p) for d,p,_ in s.paths)
    def draw(s,c,t):
        t-=s.start
        if t<0: return
        for d,path,sz in s.paths:
            tt=t-d
            if tt<0 or tt>=len(path): continue
            k=tt/len(path); col=np.array(s.col[0])*(1-k)+np.array(s.col[1])*k
            xi,yi=int(px:=path[tt][0]),int(path[tt][1])
            if 0<=xi<CW-sz and 0<=yi<CH-sz:
                if s.add: c[yi:yi+sz,xi:xi+sz]+=col
                else: c[yi:yi+sz,xi:xi+sz]=col
# ---- barrel: EoS blink lit/unlit 5 x 2 tics ----
def draw_barrel(c,mode):
    a=np.asarray(BARREL).astype(float); al=(a[...,3:]>127).astype(float); rgb=a[...,:3]
    if mode=='lit': rgb=np.clip(rgb*1.35+np.array([150,55,0]),0,255)
    h,w=al.shape[:2]; ox=BX-w//2; oy=FLOOR-h+1
    reg=c[oy:oy+h,ox:ox+w]; reg[:]=reg*(1-al)+rgb*al
BLINK=(('lit',2),('n',2),('lit',2),('n',2),('lit',2))
def banded_glow(env,col,w,h,bands=(1.0,.55,.25),px=2):
    """floor light pool as a few flat stepped bands on a 2px grid (stands in for a dynamic light); strength env(t)."""
    yy,xx=np.mgrid[0:CH,0:CW]
    xq=(xx//px)*px+px/2; yq=(yy//px)*px+px/2
    d=((xq-BX)/(w/2))**2+((yq-FLOOR)/(h/2))**2
    lv=np.zeros((CH,CW)); nb=len(bands)
    for i,b in enumerate(bands):       # band i covers d < (i+1)/nb
        lv[(d<(i+1)/nb)&(lv==0)]=b
    lv[:FLOOR]=0; lv[FLOOR]=lv[FLOOR+1]
    base3=lv[...,None]*np.array(col)
    def f(c,t):
        e=env(t)
        if e>0: c+=base3*e
    return f
def env(peak=1.0,attack=1,decay=20,start=0,steps=4):
    def e(t):
        t-=start
        if t<0: return 0
        v=peak*(t+1)/attack if t<attack else peak*max(0,1-(t-attack)/decay)**1.6
        return math.ceil(v*steps)/steps if v>0 else 0    # stepped intensity too
    return e
def render(items,pre=16,tail=10,floorlight=None,guide=False):
    nb=sum(d for _,d in BLINK); T0=pre+nb
    end=max(it.start+it.len for it in items)+tail
    frames=[]
    for t in range(T0+end):
        c=background(); tb=t-T0
        if tb<0:
            mode='n'; acc=pre
            for md,d in BLINK:
                if acc<=t<acc+d: mode=md
                acc+=d
            draw_barrel(c,mode)
        else:
            if floorlight: floorlight(c,tb)
            for it in items:
                if hasattr(it,'draw'): it.draw(c,tb); continue
                r=it.render(tb)
                if r: blit(c,*r,it.add)
        if guide: c[:,BX]=c[:,BX]*0.5+np.array([0,255,255])*0.5
        frames.append(Image.fromarray(np.clip(c,0,255).astype(np.uint8)))
    return frames,T0
