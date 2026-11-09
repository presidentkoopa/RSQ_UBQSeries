"""Context 1: blast on a liquid floor (nukage / lava / blood). Base = approved #6 Heavy (set A v3), untouched.
Modifier adds: (1) a crown splash of the liquid thrown up round the barrel, (2) liquid blobs (set-A Debris, liquid
palette, no bounce: they plop and sink), (3) a light pool mixed toward the liquid colour, (4) a stain decal left on
the floor that stays after the smoke is gone."""
import sys, math, random, numpy as np
sys.path.insert(0,'/tmp/fx_ctx2'); sys.path.insert(0,'/tmp/fx_ctx2/lib')
import ctx
from debris_v3 import Debris
W=H=320; FY=262; BX=160
LIQ={
 'nukage':dict(floor=[(22,60,12),(28,78,16),(34,92,20)],dash=(54,130,28),
               drop=[(200,255,130),(96,214,44),(44,140,24),(26,84,16)],
               stain=[(14,34,8),(30,70,14)],rim=(110,220,50),pool=(.55,.95,.25)),
 'lava':  dict(floor=[(90,18,6),(122,32,8),(170,60,10)],dash=(230,140,30),
               drop=[(255,244,170),(255,160,30),(214,70,12),(120,30,10),(60,24,18)],
               stain=[(34,20,18),(58,30,22)],rim=(255,120,20),pool=(1.0,.5,.12)),
 'blood': dict(floor=[(56,4,6),(76,8,8),(110,14,12)],dash=(170,30,28),
               drop=[(255,120,110),(214,26,22),(140,10,10),(80,6,6)],
               stain=[(40,2,4),(74,6,8)],rim=(170,20,18),pool=(1.0,.3,.22)),
}
def floor(c,L,t):
    """liquid floor in flat bands + scrolling ripple dashes (pixel, no smoothing)"""
    f=np.array(L['floor'],float)/255
    for y in range(FY,H):
        d=y-FY; c[y]=f[(d//3)%2] if d>2 else f[2]
    r=random.Random(5)
    for k in range(40):
        y=FY+3+int((r.random()**1.6)*(H-FY-6)); ln=r.randint(4,6)+int((y-FY)*0.25)
        x=(r.randrange(W)+(t//3)*(1 if k%2 else -1))%W
        c[y,x:min(W,x+ln)]=np.array(L['dash'])/255
    c[FY]=np.array(L['floor'][2])/255*1.25
DROP={2:np.array([[1,1],[1,1]]),3:np.array([[0,1,0],[1,1,1],[1,1,1],[0,1,0]]),
      4:np.array([[0,1,1,0],[1,1,1,1],[1,1,1,1],[0,1,1,0]]),5:np.array([[0,1,1,1,0],[1,1,1,1,1],[1,1,1,1,1],[1,1,1,1,1],[0,1,1,1,0]])}
class Wave:
    """liquid crest ring running out over the floor: hard 2px ellipse ring, broken into dashes, stepping darker"""
    def __init__(s,start,L,r0=34,r1=150,dur=20,seed=1):
        s.start=start; s.L=L; s.r0=r0; s.r1=r1; s.dur=dur; s.ph=random.Random(seed).random()*6
    def draw(s,c,t):
        dt=t-s.start
        if dt<0 or dt>=s.dur: return
        k=dt/s.dur; r=s.r0+(s.r1-s.r0)*(1-(1-k)**2)
        pal=[np.array(p,float)/255 for p in s.L['drop']]
        col=pal[min(len(pal)-1,dt//5)]; hi=pal[min(len(pal)-1,dt//5)] if dt>=5 else pal[0]
        for i in range(int(r*4)):
            a=2*math.pi*i/int(r*4)
            if (math.sin(a*9+s.ph+dt*0.3))<-0.35: continue      # broken crest
            x=int(round(BX+math.cos(a)*r)); y=int(round(FY+2+math.sin(a)*r*0.2))
            hgt=2 if math.sin(a)>0 else 1
            if 1<=x<W-1 and FY<=y-hgt and y<H:
                c[y-hgt:y+1,x]=col; c[y-hgt,x]=hi
class Jet:
    """fat liquid jet: a hard-pixel column from the floor, rising then sinking back; bulb on top, highlight left edge.
    When it tops out it sheds a few drops (handled by a Crown spawned at its top)."""
    def __init__(s,start,L,x,w=6,vz=9,g=0.6,lean=0.0):
        s.start=start; s.L=L; s.x=x; s.w=w; s.vz=vz; s.g=g; s.lean=lean
        s.peak=vz/g; s.dur=2*s.peak
    def top(s,dt): return s.vz*dt-0.5*s.g*dt*dt
    def draw(s,c,t):
        dt=t-s.start
        if dt<0 or dt>=s.dur: return
        pal=[np.array(p,float)/255 for p in s.L['drop']]
        zt=int(s.top(dt))
        if zt<2: return
        body=pal[1] if dt<s.peak else pal[2]; hi=pal[0] if dt<s.peak else pal[1]; dk=pal[min(len(pal)-1,3)]
        sg=1 if s.lean>=0 else -1
        for z in range(0,zt+1):
            f=z/max(1,zt)
            w=max(2,int(round(s.w*(1-f)**0.75)))           # spike: wide foot, pointed tip
            x0=int(round(s.x+s.lean*z+sg*1.2*s.w*f*f-w/2)); y=FY-z    # curls outward near the top
            if y<1 or x0<0 or x0+w>=W: continue
            c[y,x0:x0+w]=body; c[y,x0:x0+max(1,w//3)]=hi if sg<0 else dk; c[y,x0+w-max(1,w//3):x0+w]=dk if sg<0 else hi
        if dt<s.peak+3:                                    # drop riding the tip
            m=DROP[4]; xt=int(round(s.x+s.lean*zt+sg*1.2*s.w))-2+sg*2; yt=FY-zt-6-int(dt*0.6)
            for yy in range(4):
                for xx in range(4):
                    if m[yy,xx] and 0<=yt+yy<H and 0<=xt+xx<W: c[yt+yy,xt+xx]=hi if yy==0 else body
class Crown:
    """ring of liquid droplets kicked up round the barrel foot, falling back; front half drawn in front of the blast"""
    def __init__(s,start,L,n=36,seed=3,r0=(10,30),vz=(5,10.5),vr=(0.6,2.2),k=1.0,sizes=(3,4,5),g=0.6):
        rr=random.Random(seed); s.p=[]; s.L=L; s.start=start
        for i in range(n):
            a=2*math.pi*i/n+rr.uniform(-.08,.08)
            s.p.append(dict(a=a,r=rr.uniform(*r0)*k,vz=rr.uniform(*vz)*k,vr=rr.uniform(*vr)*k,t0=start+rr.randint(0,3),sz=rr.choice(sizes)))
        s.g=g*k
    def draw(s,c,t,front):
        pal=[np.array(p,float)/255 for p in s.L['drop']]
        for p in s.p:
            if (math.sin(p['a'])>0)!=front: continue
            dt=t-p['t0']
            if dt<0: continue
            z=p['vz']*dt-0.5*s.g*dt*dt; r=p['r']+p['vr']*dt
            x=BX+math.cos(p['a'])*r*1.9; yb=FY+2+(math.sin(p['a'])+1)*r*0.16   # whole ring lies on the floor plane
            if z<0:      # landed: one-tic plop ring, then gone
                tl=dt-2*p['vz']/s.g
                if tl<2:
                    xi,yi=int(x),int(yb)
                    if 0<=yi<H and 3<=xi<W-4: c[yi,xi-3:xi+4]=pal[2]
                continue
            sz=p['sz']; xi=int(round(x))-sz//2; yi=int(round(yb-z))-sz
            col=pal[min(len(pal)-2,1+dt//8)]
            vz=p['vz']-s.g*dt
            if 0<=xi<W-sz and 2<=yi<H-sz-4:
                m=DROP[sz]
                if abs(vz)>3: m=np.vstack([m,m[-1:]])          # stretched while fast (hard pixels)
                for yy in range(m.shape[0]):
                    for xx in range(m.shape[1]):
                        if m[yy,xx]: c[yi+yy,xi+xx]=pal[0] if (yy==0 or (yy==1 and xx==0)) and m[yy,xx]==1 else (pal[min(len(pal)-1,3)] if yy==m.shape[0]-1 and sz>2 else col)
class Stain:
    """hard-edged decal: grows over 3 tics, holds, the rim band steps away; lava's rim glows then cools"""
    def __init__(s,start,L,rx=72,ry=13,seed=9):
        s.start=start; s.L=L; rr=random.Random(seed)
        yy,xx=np.mgrid[0:2*ry+1,0:2*rx+1]; ang=np.arctan2((yy-ry)*rx/ry,xx-rx)
        wob=1+0.12*np.sin(3*ang+rr.random()*6)+0.07*np.sin(7*ang+rr.random()*6)
        d=np.sqrt(((xx-rx)/rx)**2+((yy-ry)/ry)**2)/wob
        s.d=d; s.rx,s.ry=rx,ry
    def draw(s,c,t,lava=False):
        dt=t-s.start
        if dt<0: return
        g=min(1,(dt+1)/3)
        core=np.array(s.L['stain'][0])/255; mid=np.array(s.L['stain'][1])/255; rim=np.array(s.L['rim'])/255
        m_core=s.d<0.55*g; m_mid=(s.d<0.85*g)&~m_core; m_rim=(s.d<1.0*g)&~m_core&~m_mid
        y0=FY+1; x0=BX-s.rx
        sub=c[y0-s.ry//2:y0-s.ry//2+s.d.shape[0],x0:x0+s.d.shape[1]]
        sub[m_core]=core; sub[m_mid]=mid
        rim_on=dt<40 if not lava else dt<70
        if rim_on:
            rc=rim if dt<16 else (rim*0.6 if dt<30 else rim*0.35)
            sub[m_rim]=rc
def shot(kind,base='heavy'):
    L=LIQ[kind]; C,O,lt=ctx.plate(base); S=ctx.Scene(W,H,FY)
    T0=ctx.T0
    sd={'nukage':3,'lava':4,'blood':5}[kind]
    crown=Crown(T0+3,L,n=44,seed=sd,r0=(26,36),vz=(5,8),vr=(1.6,2.8),sizes=(3,4,4,5),g=0.5)       # wide crown, outside the ball
    crown2=Crown(T0+6,L,n=26,seed=sd+10,r0=(8,20),vz=(9,12),vr=(0.4,1.2),sizes=(2,3,4),g=0.55)     # tall spout, seen as the ball shrinks
    jets=[Jet(T0+4,L,BX-74,w=12,vz=7,g=0.55,lean=-0.3),Jet(T0+4,L,BX+74,w=12,vz=7,g=0.55,lean=0.3),
          Jet(T0+5,L,BX-52,w=10,vz=8,g=0.55,lean=-0.15),Jet(T0+5,L,BX+52,w=10,vz=8,g=0.55,lean=0.15)]
    crown3=Crown(T0+10,L,n=18,seed=sd+20,r0=(0,10),vz=(8,10.5),vr=(0.2,0.9),sizes=(4,5,5),g=0.5)   # late spout where the barrel stood
    waves=[Wave(T0+2,L,seed=1),Wave(T0+8,L,r0=24,r1=110,dur=18,seed=2)]
    stain=Stain(T0+2,L)
    blobs=[Debris(T0+3,BX+0.5,FY,1.25,cscale=1/255,n=14,seed=21,z0=(10,26),x0=(10,22),speed=(4,7.5),spread=(28,70),grav=1.0,
                  bounce=(0.0,0.05),friction=0.2,palettes=[(1,L['drop'][1:])],cool=(4,6),shapes=('sq','chunk','L','sq'),px=3,
                  hold=(3,6),depth=(0,14),spawn=0.5,exact=True,until=34)]
    pool=np.array(L['pool']); fire=np.array((1.0,.55,.2))
    T=len(C)+10; frames=[]
    for t in range(T):
        c=S.blank(); floor(c,L,t)
        stain.draw(c,t,lava=(kind=='lava'))
        for w_ in waves: w_.draw(c,t)
        tp=min(t,len(C)-1)
        S.pool(c,BX+0.5,lt(t),col=tuple(fire*0.45+pool*0.55))
        b=ctx.barrel_img(t,T0)
        if b: S.sprite(c,b,BX,FY+2)            # sits 2px into the liquid
        for fr_ in (False,True): crown.draw(c,t,fr_); crown2.draw(c,t,fr_)
        for d in blobs: d.draw(c,t)
        for j in jets[:4]: j.draw(c,t)
        crown3.draw(c,t,False); crown3.draw(c,t,True)
        if t<len(C): S.comp(c,C[tp],O[tp],(ctx.PBX,ctx.PFY),BX,FY)
        for d in blobs: pass
        frames.append(ctx.to_img(c))
    return frames
KEY=[16,18,19,21,23,26,30,36,44,56,70]
if __name__=='__main__':
    for k in (sys.argv[1:] or LIQ):
        fr=shot(k)
        ctx.save(fr,f'/tmp/fx_ctx2/out/C_liquid_{k}_full.gif'); ctx.save(fr,f'/tmp/fx_ctx2/out/C_liquid_{k}_half.gif',slow=2)
        for i,f in enumerate(fr): f.save(f'/tmp/fx_ctx2/look/liq_{k}_{i:03d}.png')
        print(k,len(fr))
