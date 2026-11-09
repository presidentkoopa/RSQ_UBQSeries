"""Context 3: crowd kill. A barrel among imps; one blast kills several at once. Base = approved #6 Heavy (x1.0).
Modifier when one blast kills N>=3 monsters:
  - each of those deaths becomes a gib burst (MeatGrinder MGAB blood spray + MGAG chunks + hard-pixel bits in the
    monster's own colours and blood red), and
  - a beat of slow motion: game tics after the kill are HELD (each frame shown 3x, then 2x), the first two held tics
    tinted flat (cream flash, then red) - no smooth slow-down, no blur.
Imps: front frames of tier folders T01 (green), T04 (pink), T10 (red), T02 (blue), T05 (brown), Imp sprites read-only."""
import sys, math, random, numpy as np
sys.path.insert(0,'/tmp/fx_ctx2'); sys.path.insert(0,'/tmp/fx_ctx2/lib')
import ctx, imps
from PIL import Image
from debris_v3 import Debris
W,H,FY,BX=640,360,300,320
T0=ctx.T0
MG='/home/claude/rsq_ubqseries/Monsters/sprites/meatgrinder/'
def mg(n): return Image.open(MG+n+'.png').convert('RGBA')
BURST=[mg(f'MGAB{c}0') for c in 'ABCDEFGH']          # blood spray, 128x128, grAb 64,64 (centre)
CHUNKS=[mg(f'MGAG{c}0') for c in 'ABCDEFGH']         # 6-8 px meat/bone bits
BLOOD=[(236,40,30),(176,14,12),(118,6,6),(80,4,4),(56,4,4)]
def sc(im,k): return im.resize((max(1,round(im.width*k)),max(1,round(im.height*k))),Image.NEAREST)
def white(im): a=np.array(im).copy(); a[...,:3]=255; return Image.fromarray(a)
def tintim(im,col,k=0.6):
    a=np.array(im).astype(float); a[...,:3]=a[...,:3]*(1-k)+np.array(col)*k; return Image.fromarray(a.astype(np.uint8))
def own_palette(im,n=5):
    """the monster's own colours, light to dark, from its opaque pixels (for its gib bits)"""
    a=np.array(im).reshape(-1,4); a=a[a[:,3]>0][:,:3].astype(float)
    sat=a.max(1)-a.min(1); a=a[sat>=np.percentile(sat,40)]                 # its body colour, not the grey spikes
    l=a@[.3,.59,.11]; q=np.percentile(l,np.linspace(92,15,n))
    return [tuple(int(v) for v in a[np.argmin(abs(l-x))]) for x in q]
class Chunks:
    """MGAG meat chunks thrown from a body: arc, tumble 90 deg every 2 tics, land, sit, blink out"""
    def __init__(s,start,x,z,n=8,seed=1,k=2):
        r=random.Random(seed); s.p=[]
        for i in range(n):
            sg=-1 if i%2 else 1; a=math.radians(r.uniform(15,75)); v=r.uniform(4,8)
            s.p.append(dict(im=sc(CHUNKS[r.choice([4,5,6,7])],k),x=x,z=z,vx=sg*math.sin(a)*v*r.uniform(.7,1.3),vz=math.cos(a)*v,
                            d=r.uniform(0,22),rot=r.randrange(4),hold=r.randint(14,24),t0=start))
        s.g=0.8
    def draw(s,S,c,t):
        for p in s.p:
            dt=t-p['t0']
            if dt<0: continue
            land=(p['vz']+math.sqrt(p['vz']**2+2*s.g*p['z']))/s.g
            tt=min(dt,land); x=p['x']+p['vx']*tt; z=p['z']+p['vz']*tt-.5*s.g*tt*tt
            if dt>land+p['hold']: continue
            rem=land+p['hold']-dt
            if rem<=4 and int(rem)%2==0: continue
            im=p['im'].rotate(90*((p['rot']+dt//2)%4 if dt<land else p['rot']),expand=True)
            S.sprite(c,im,x,FY+p['d']*min(1,dt/max(1,land))-max(0,z))
def shot(slowmo=True):
    S=ctx.Scene(W,H,FY)
    C,O,lt=ctx.plate('heavy')
    TIERS=[('T05',-150),('T01',-82),('T10',82),('T02',150)]
    mons=[]
    for i,(tier,dx) in enumerate(TIERS):
        A=sc(imps.front(tier,'A'),1.25); B=sc(imps.front(tier,'B'),1.25)
        x=BX+dx; flip=dx>0
        if flip: A=A.transpose(Image.FLIP_LEFT_RIGHT); B=B.transpose(Image.FLIP_LEFT_RIGHT)   # all face the barrel
        pal=own_palette(A)
        mons.append(dict(A=A,B=B,x=x,pal=pal,ph=i*3,
            chunks=Chunks(T0+3,x,A.height*0.55,n=6,seed=10+i,k=1.5),
            bits=[Debris(T0+3,x+0.5,FY,1.25,cscale=1/255,n=12,seed=30+i,z0=(18,40),x0=(2,10),speed=(3,7),spread=(15,80),grav=1.0,
                         bounce=(.15,.25),friction=.4,palettes=[(2,BLOOD),(1,pal)],cool=(6,8),shapes=('sq','chunk','L','slab'),px=2,
                         hold=(14,24),depth=(0,18),spawn=.3,exact=True,until=40)]))
    T=len(C)+8; game=[]
    for t in range(T):
        c=S.blank(); S.pool(c,BX+0.5,lt(t))
        b=ctx.barrel_img(t,T0)
        if b: S.sprite(c,b,BX,FY)
        for m in mons:
            if t<T0+1: im=m['A'] if ((t+m['ph'])//8)%2==0 else m['B']
            elif t==T0+1: im=white(m['A'])                 # hit: 1 tic white
            elif t==T0+2: im=tintim(m['A'],(255,40,30))     # 1 tic red
            else: im=None                                    # gibbed
            if im: S.sprite(c,im,m['x'],FY)
        if t<len(C): S.comp(c,C[t],O[t],(ctx.PBX,ctx.PFY),BX,FY)
        for m in mons:
            j=t-(T0+3)
            if 0<=j<12:                                      # MGAB burst: 1 tic per frame for 4, then 2 tics
                fi=j if j<4 else 4+(j-4)//2
                if fi<8: S.sprite(c,sc(BURST[fi],1.5),m['x'],FY-m['A'].height*0.55,anchor='c')
            if j==0: S.sprite(c,white(m['A']),m['x'],FY,a=0.9)   # the body pops: white flash of its shape
            for d in m['bits']: d.draw(c,t)
            m['chunks'].draw(S,c,t)
        game.append(c)
    # slow motion beat on the kill: held frames + flat tint, all in frame repeats (GIF tic length unchanged)
    HOLD={T0+3:3,T0+4:3,T0+5:3,T0+6:3,T0+7:2,T0+8:2,T0+9:2,T0+10:2}
    out=[]
    for t,c in enumerate(game):
        n=HOLD.get(t,1) if slowmo else 1
        for k in range(n):
            f=c
            if slowmo and t==T0+3 and k==0: f=flat(c,(255,236,190),(60,20,10))     # cream flash
            elif slowmo and (t==T0+3 and k>0 or t==T0+4): f=flat(c,(255,70,50),(26,0,6))   # red beat
            out.append(ctx.to_img(f))
    return out
def flat(c,hi,lo):
    """flat two-band tint of the whole scene by brightness (no gradients): dark band, mid band, light band"""
    L=ctx.lum(np.clip(c,0,1)); hi=np.array(hi)/255; lo=np.array(lo)/255; mid=(hi+lo)/2
    out=np.where((L>.45)[...,None],hi,np.where((L>.12)[...,None],mid,lo))
    return out.astype(np.float32)
if __name__=='__main__':
    fr=shot(); print(len(fr))
    ctx.save(fr,'/tmp/fx_ctx2/out/C_crowd_full.gif'); ctx.save(fr,'/tmp/fx_ctx2/out/C_crowd_half.gif',slow=2)
    for i,f in enumerate(fr): f.save(f'/tmp/fx_ctx2/look/crowd_{i:03d}.png')
