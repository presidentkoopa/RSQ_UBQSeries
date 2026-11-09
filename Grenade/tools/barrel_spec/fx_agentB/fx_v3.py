# v3 compositor additions on top of fx_v2 (fx_v2 untouched).
#  - LC: layer whose drawn art (after scale, roll, squash, floor clip) is re-centred every tic on the barrel centre line.
#    The old v2 centring happened on the source frame before roll/squash, which let lopsided or off-cell art drift
#    (flattened floor rings measured +3..+6 px right, bbox up to +9.5 px).
#  - Debris (debris_v3): bouncing, settling hard-pixel bits.
import numpy as np
from fx_v2 import *
from fx_v2 import L as _L
from debris_v3 import Debris as _Debris
BC=BX+0.5                    # barrel centre line in continuous canvas x (barrel bbox 134..187 -> 160.5)
def xcentre(al,mode):
    cols=al.sum(0)
    if cols.sum()==0: return None
    xs=np.arange(al.shape[1])+0.5
    cen=(cols*xs).sum()/cols.sum()
    if mode=='cent': return cen
    nz=np.nonzero(cols>=2)[0]
    if len(nz)==0: nz=np.nonzero(cols)[0]
    bb=(nz.min()+nz.max()+1)/2
    return bb if mode=='bbox' else (bb+cen)/2
class LC(_L):
    """xc: 'bbox' (outline extents: rings), 'cent' (mass: puffs), 'mix' (both: fireballs). dx: intended offset in px."""
    def __init__(s,*a,xc='mix',dx=0.0,autoroll=False,**kw):
        super().__init__(*a,**kw); s.xc=xc; s.dx=dx
        if autoroll: s.pick_roll(autoroll)
    def pick_roll(s,step):
        """choose the roll (the EoS roll is random anyway) at which the drawn art is most balanced left/right:
        smallest gap between its mass centre and outline centre over the whole life of the layer."""
        step=10 if step is True else step; best=None; xc=s.xc; s.xc=None
        for rot in range(0,360,step):
            s.rot=rot; sc=0
            for t in range(s.start,s.start+s.len):
                r=_L.render(s,t)
                if r is None: continue
                al=r[1]
                if al.sum()==0: continue
                sc+=abs(xcentre(al,'cent')-xcentre(al,'bbox'))
            if best is None or sc<best[0]: best=(sc,rot)
        s.rot=best[1]; s.xc=xc
    def render(s,t):
        r=super().render(t)
        if r is None or not s.xc: return r
        rgb,al,m,ox,oy=r
        if s.clip:   # measure what is actually drawn (floor-clipped)
            cut=int(FLOOR+1-oy)
            if cut<al.shape[0]: al=al.copy(); al[max(0,cut):]=0
        if s.xc=='sym':   # floor rings: mirror the left half of the drawn ring onto the right -> exactly symmetric about the line
            nz=np.nonzero(al.sum(0))[0]
            if len(nz)==0: return r
            a0,a1=nz.min(),nz.max()+1; al=al[:,a0:a1].copy(); rgb=rgb[:,a0:a1].copy(); w=a1-a0
            al[:,w-w//2:]=al[:,:w//2][:,::-1]; rgb[:,w-w//2:]=rgb[:,:w//2][:,::-1]
            tt=t-s.start
            return rgb,al,m,int(round(BC+s.dx+(s.pos[0]-BX)+s.vel[0]*tt-w/2)),oy
        c=xcentre(al,s.xc)
        if c is None: return r
        tt=t-s.start
        want=BC+s.dx+s.vel[0]*tt+0.5*s.acc[0]*tt*tt+(s.pos[0]-BX)
        return rgb,al,m,ox+int(round(want-(ox+c))),oy
def Debris(start,**kw): return _Debris(start,BC,FLOOR,U,**kw)
def lc_child(frames,tic,z,size,rng,dtic=1,eos=True,autoroll=10,**kw):
    """ExplosmChild on the centre line (EoS x-scale creep 1.04-1.08/tic for 5 tics, mild y squash), random roll."""
    tl=dtic if isinstance(dtic,list) else [dtic]*len(frames)
    pre=None
    if eos:
        ry=rng.uniform(.7,.9); g=rng.uniform(1.04,1.08); pre=[(g**min(i,5),ry) for i in range(sum(tl))]
    return LC(frames,tl,start=tic,pos=(BX,Z(z)),size=size,rot=rng.randint(0,359),presq=pre,autoroll=autoroll,**kw)
def lc_main(frames,dtic,rot,size,z=MAINZ,silcol=(255,255,255),autoroll=10,**kw):
    fr=[frames[0],frames[0]]+list(frames[1:]); tl=[1,2]+(dtic if isinstance(dtic,list) else [dtic]*(len(frames)-1))
    return LC(fr,tl,start=0,pos=(BX,Z(z)),size=size,rot=rot,sil=(1,3),silcol=silcol,autoroll=autoroll,**kw)
def lc_pops(rng,ramp_,size=34,z=4,start=0,gain=1.2):
    st=strip('r276')[15].rotate(90,expand=True)
    a=rng.randint(0,359); out=[]
    for i in range(3):
        out.append(LC([st],[3],start=start,pos=(BX,Z(z)),size=size,rot=a,presq=[(1,.4),(.8,.55),(.7,.8)],
                      alist=[.8,.6,.3],ramp=ramp_,gain=gain,clip=True,xc='mix'))
        a+=rng.randint(90,130)
    return out
class EmbersC(Embers):
    """BarrelFire embers in exact mirrored pairs (same |x|, z and lift for the two sides; only the tumble differs),
    using frames re-centred on their art (v2 used raw cells)."""
    def __init__(s,start,seed=1,ramp_=None,gain=1.0,scale=1.25,grav=1.0,n_tics=7):
        rng=random.Random(seed); s.items=[]
        fr=strip('sparks/RSS0[A-D]0.png','bbox')
        for t in range(n_tics):
            r=rng.uniform(4,26); x=rng.uniform(r*.15,r); z=rng.uniform(16,32); vz=rng.uniform(6,12)
            for sgn in (-1,1):
                tl=[rng.choice([2,3]) for _ in fr]; rot=rng.choice([0,90,180,270])
                s.items.append((start+t,sgn*x,z,vz,L(fr,tl,start=0,scale=scale,rot=rot,ramp=ramp_,gain=gain,clip=False,fade=.6)))
        s.grav=grav; s.start=start; s.len=max(st+it.len for st,_,_,_,it in s.items)-start
    def draw(s,c,t):
        for st,x,z,vz,it in s.items:
            tt=t-st
            if tt<0 or tt>=it.len: continue
            zz=z+vz*tt-0.5*s.grav*tt*tt
            if zz<0: continue
            it.pos=(BC+x*U,Z(zz)); r=it.render(tt)
            if r:
                rgb,al,m,ox,oy=r
                c0=xcentre(al,'bbox'); ox=int(round(BC+x*U-c0)) if c0 is not None else ox
                blit(c,rgb,al,m,ox,oy,True)
def render3(items,guide=False,**kw):
    fr,T0=render(items,**kw)
    if guide:
        out=[]
        for f in fr:
            a=np.asarray(f).copy(); a[:,BX]=(a[:,BX]*.4+np.array([0,255,255])*.6).astype(np.uint8)   # pixel 160 = right of the 160.5 line

            out.append(Image.fromarray(a))
        fr=out
    return fr,T0
