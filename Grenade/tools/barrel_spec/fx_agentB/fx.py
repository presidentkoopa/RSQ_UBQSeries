# Agent B FX compositor (extended from anim_base.py)
import os,glob,math,random
import numpy as np
from PIL import Image,ImageDraw
CF='/home/claude/rsq_ubqseries/Monsters/sprites/combatfx'
CW=CH=320; FLOOR=262; BX=160; U=1.6; BH=round(42*U)
BOT=(BX,FLOOR-4); TOP=(BX,FLOOR-BH)
def MID(side): return (BX+side*round(10*U),FLOOR-BH//2)
_cache={}
def strip(key):
    """key: eosfr name, cut/<name>, or combatfx glob like 'smoke/RSK1?0'"""
    if key in _cache: return _cache[key]
    if os.path.isdir(f'/tmp/eosfr/{key}'): fs=sorted(glob.glob(f'/tmp/eosfr/{key}/*.png'))
    elif os.path.isdir(f'/tmp/fx_agentB/cut/{key}'): fs=sorted(glob.glob(f'/tmp/fx_agentB/cut/{key}/*.png'))
    else: fs=sorted(glob.glob(f'{CF}/{key}'),key=lambda p:os.path.basename(p)[:6].upper())
    assert fs,key
    _cache[key]=[Image.open(p).convert('RGBA') for p in fs]; return _cache[key]
def pick(key,idx): s=strip(key); return [s[i] for i in idx]
# ---- colour ramps (gradient map by brightness) ----
def ramp(*stops):
    """stops: (pos 0..1, (r,g,b)) -> 256x3 LUT"""
    xs=[p for p,_ in stops]; cs=np.array([c for _,c in stops],float)
    t=np.linspace(0,1,256); return np.stack([np.interp(t,xs,cs[:,i]) for i in range(3)],1)
R_HOT=ramp((0,(40,0,0)),(.35,(170,30,0)),(.6,(255,120,10)),(.82,(255,220,90)),(1,(255,255,235)))
R_SHOCK=ramp((0,(30,10,0)),(.4,(200,90,20)),(.7,(255,200,120)),(1,(255,250,240)))
R_DUST=ramp((0,(20,16,12)),(.5,(85,72,58)),(.8,(140,122,98)),(1,(185,170,145)))
R_SOOT=ramp((0,(14,12,11)),(.45,(58,50,44)),(.8,(104,94,84)),(1,(150,140,128)))
R_DIRTY=ramp((0,(10,6,4)),(.35,(90,40,15)),(.65,(215,105,30)),(.88,(255,200,80)),(1,(255,238,170)))
R_EMBER=ramp((0,(10,0,0)),(.5,(120,20,0)),(.8,(230,90,10)),(1,(255,190,80)))
R_NEON=ramp((0,(30,0,40)),(.35,(150,0,110)),(.6,(255,40,140)),(.8,(255,150,90)),(1,(255,250,220)))
R_MINT=ramp((0,(0,20,20)),(.4,(0,120,110)),(.7,(80,255,200)),(1,(240,255,245)))
R_GOLD=ramp((0,(30,10,0)),(.4,(170,90,0)),(.7,(255,200,40)),(1,(255,255,220)))
def lum(a): return (a[...,0]*.3+a[...,1]*.59+a[...,2]*.11)/255.
class L:
    def __init__(s,frames,tics,start=0,pos=(BX,FLOOR),size=None,scale=None,grow=0.0,rot=0,flip=False,squash=1.0,
                 ramp=None,cool=0.0,bright=1.0,add=True,alpha=1.0,fade=None,fadein=0,vel=(0,0),acc=(0,0),spin=0,
                 sil=0,anchor='c',ease=1.0,floor=False,gain=1.0,xs=1.0,clip=None):
        s.fr=frames; s.tl=tics if isinstance(tics,list) else [tics]*len(frames)
        assert len(s.tl)==len(s.fr)
        s.start=start; s.pos=pos; s.grow=grow; s.rot=rot; s.flip=flip; s.sq=squash; s.ramp=ramp; s.cool=cool
        s.bright=bright; s.add=add; s.alpha=alpha; s.fade=fade; s.fadein=fadein; s.vel=vel; s.acc=acc; s.spin=spin
        s.sil=sil; s.anchor=anchor; s.ease=ease; s.floor=floor; s.gain=gain; s.xs=xs; s.clip=(squash>=.5) if clip is None else clip
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
        im=im.resize((max(1,round(im.width*sc)),max(1,round(im.height*sc))),Image.NEAREST)
        if s.flip: im=im.transpose(Image.FLIP_LEFT_RIGHT)
        rot=s.rot+s.spin*tt
        if rot: im=im.rotate(rot,expand=True,resample=Image.NEAREST)
        if s.sq!=1 or s.xs!=1: im=im.resize((max(1,round(im.width*s.xs)),max(1,round(im.height*s.sq))),Image.NEAREST)
        a=np.asarray(im).astype(float)
        rgb=a[...,:3]; al=a[...,3]/255.
        if s.sil and tt<s.sil: rgb=np.full_like(rgb,255.)
        elif s.ramp is not None:
            p=np.clip(lum(a)*s.gain*(1-s.cool*k),0,1); rgb=s.ramp[(p*255).astype(int)]
        m=s.alpha*s.bright
        if s.fade is not None and k>s.fade: m*=max(0,1-(k-s.fade)/(1-s.fade+1e-9))
        if s.fadein and tt<s.fadein: m*=(tt+1)/(s.fadein+1)
        x=s.pos[0]+s.vel[0]*tt+0.5*s.acc[0]*tt*tt; y=s.pos[1]+s.vel[1]*tt+0.5*s.acc[1]*tt*tt
        h,w=al.shape
        if s.floor and y+h/2>FLOOR: y=FLOOR-h/2+1
        ox=int(round(x-w/2)); oy=int(round(y-(h if s.anchor=='b' else h/2)))
        if s.clip:  # sprite clipped by the floor plane
            cut=FLOOR+1-oy
            if cut<h: al=al.copy(); al[max(0,cut):]=0
        return rgb,al,m,ox,oy
class Sparks:
    """engine particles (A_SpawnParticle-style squares), simulated per tic with gravity, drag and floor bounce"""
    def __init__(s,n,start,pos,speed=(2,5),life=(6,12),g=0.35,col=((255,240,180),(255,120,20)),sz=2,seed=1,spread=180,
                 add=True,drag=0.95,bounce=0.3,trail=True,szr=(0,0)):
        rnd=random.Random(seed); s.start=start; s.col=col; s.add=add; s.trail=trail; s.paths=[]
        for i in range(n):
            ang=math.radians(rnd.uniform(-spread/2,spread/2)-90); v=rnd.uniform(*speed)*U
            x=pos[0]+rnd.uniform(-3,3)*U; y=pos[1]+rnd.uniform(-3,3)*U; vx=math.cos(ang)*v; vy=math.sin(ang)*v
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
            k=tt/len(path)
            col=np.array(s.col[0])*(1-k)+np.array(s.col[1])*k
            pts=[(path[tt],sz,1.0)]
            if s.trail and tt>0:
                (x0,y0),(x1,y1)=path[tt-1],path[tt]
                pts.append((((x0+x1)/2,(y0+y1)/2),max(1,sz-1),0.5))
            for (px,py),z,f in pts:
                xi,yi=int(px),int(py)
                if 0<=xi<CW-z and 0<=yi<CH-z:
                    if s.add: c[yi:yi+z,xi:xi+z]+=col*f*(1-0.4*k)
                    else: c[yi:yi+z,xi:xi+z]=col
# ---- barrel ----
BARREL=Image.open('/tmp/fx_agentB/cut/barrel.png').convert('RGBA')
BARREL=BARREL.resize((round(BARREL.width*1.45*U),round(BARREL.height*1.45*U)),Image.NEAREST)
def draw_barrel(c,mode):
    a=np.asarray(BARREL).astype(float); al=a[...,3:]/255.; rgb=a[...,:3]
    if mode=='white': rgb=np.full_like(rgb,255.)
    elif mode=='hot': rgb=np.clip(rgb*1.3+np.array([140,40,0]),0,255)
    elif mode=='blink': rgb=np.clip(rgb*1.6+60,0,255)
    h,w=al.shape[:2]; ox=BX-w//2; oy=FLOOR-h+1
    reg=c[oy:oy+h,ox:ox+w]; reg[:]=reg*(1-al)+rgb*al
def background():
    c=np.zeros((CH,CW,3)); c[:]=(8,8,12)
    c[FLOOR+1:]=(16,15,18)
    # faint perspective floor lines so the floor reads as a plane
    for i in range(1,6):
        y=FLOOR+1+int(i*i*2.6)
        if y<CH: c[y,:]=(24,23,27)
    c[FLOOR,:]=(70,68,76)
    return c
def blit(c,rgb,al,m,ox,oy,add):
    h,w=al.shape
    x0,y0=max(0,ox),max(0,oy); x1,y1=min(CW,ox+w),min(CH,oy+h)
    if x1<=x0 or y1<=y0: return
    r=rgb[y0-oy:y1-oy,x0-ox:x1-ox]; a=(al[y0-oy:y1-oy,x0-ox:x1-ox]*m)[...,None]
    if add: c[y0:y1,x0:x1]+=r*a
    else: c[y0:y1,x0:x1]=c[y0:y1,x0:x1]*(1-np.clip(a,0,1))+r*np.clip(a,0,1)
def render(items,pre=16,blink=(('blink',1),('n',1),('hot',1),('n',1),('blink',1),('white',2)),tail=14,floorlight=None):
    """items: list of L / Sparks with start relative to blast tic 0. Barrel stands for pre tics then blinks."""
    nb=sum(d for _,d in blink); T0=pre+nb
    end=max((it.start+it.len) for it in items)+tail
    frames=[]
    for t in range(T0+end):
        c=background()
        tb=t-T0
        if tb<0:
            mode='n'; acc=pre
            for md,d in blink:
                if t>=acc and t<acc+d: mode=md
                acc+=d
            draw_barrel(c,mode)
        else:
            if floorlight: floorlight(c,tb)
            for it in items:
                if isinstance(it,Sparks): it.draw(c,tb); continue
                r=it.render(tb)
                if r: blit(c,*r,it.add)
        frames.append(Image.fromarray(np.clip(c,0,255).astype(np.uint8)))
    return frames,T0
def glow(env,col=(255,140,40),w=150,h=26,y=FLOOR):
    """floor dynamic light: additive ellipse whose strength follows env(t) (0..1)"""
    yy,xx=np.mgrid[0:CH,0:CW]
    d=((xx-BX)/(w/2))**2+((yy-y)/(h/2))**2
    base=np.clip(1-d,0,1)**1.5; base[:y-2]*=0.0  # only on/under the floor line
    base3=base[...,None]*np.array(col)
    def f(c,t):
        e=env(t)
        if e>0: c+=base3*e
    return f
def save_gif(frames,path,slow=1):
    fr=[f.resize((CW*2,CH*2),Image.NEAREST) for f in frames]
    pat=[30,30,30,30,30,30,20] if slow==1 else [60,60,60,50,60,60,50]
    dur=[pat[i%7] for i in range(len(fr))]
    q=[f.quantize(256,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE) for f in fr]
    q[0].save(path,save_all=True,append_images=q[1:],duration=dur,loop=0,disposal=1)
