# GRENADE (frag) blast: floor and mid-air versions, plus per-kind tints. Builds on the barrel sets' EoS structure:
#   tic 0      main: 8-point star crack 1 tic, the same star as a 2-tic solid white silhouette, then a white ball opening
#              into a ring (Rufaswan); 3 flat streak pops at the base
#   tics 0-2   SHRAPNEL: hard pixel streaks, ~44, out to 200-255 units in ~5 tics; floor hits leave hot pepper marks
#   tics 3,4,5 one small fast child fireball per tic within 12 units (Reactorcore ring-flash, 1 tic a frame: crack, not fuel)
#   tics 3-9   RSS0 pixel embers, 2 per tic for 7 tics
#   ring 1 (200 units) from tic 1, ring 2 (255 units, the second A_Explode) from tic 3
#   debris: hard dark bits thrown out that bounce and settle; blocky soot puffs after
import sys,math,random
import numpy as np
from PIL import Image,ImageDraw
import fxg
from fxg import *
SRC='/tmp/fx_agentG/src/'
# ------------------------------------------------------------------ grenade sprite (preview only)
def _nade(f,w):
    im=Image.open(SRC+f+'.png').convert('RGBA'); im=im.crop(im.getbbox())
    s=w/im.width; return im.resize((max(1,round(im.width*s)),max(1,round(im.height*s))),Image.NEAREST)
TUMBLE=[_nade('QGNT%s0'%c,16) for c in 'ABCDEF']
REST=_nade('QGNTG0',17)
def nade_draw(c,im,x,y,mode):
    a=np.asarray(im).astype(float); al=(a[...,3]>127).astype(float); rgb=a[...,:3]
    if mode=='red':   rgb=np.stack([np.clip(lum(a)*255*1.6+90,0,255),lum(a)*255*.25,lum(a)*255*.2],-1)   # nade_red skin look
    if mode=='white': rgb=np.full_like(rgb,255.)
    if mode=='n': rgb=np.clip(rgb*1.5+12,0,255)      # a touch brighter so it reads on the dark preview floor
    h,w=al.shape; blit(c,rgb,al,1.0,int(round(x-w/2)),int(round(y-h/2)),False)
def blink_mode(t,on_tics):
    return 'red' if t in on_tics else 'n'
def fuse_schedule(t_end=-1,gaps=(9,8,7,6,5,4,3,3,2,2,1,1)):
    """red flashes faster and faster up to the blast; each red flash 1-2 tics; tic -1 is the white flash"""
    on=set(); t=t_end-1
    for g in gaps[::-1]:
        on.add(t);
        if g>=4: on.add(t-1)
        t-=g+ (2 if g>=4 else 1)
    return on
# ------------------------------------------------------------------ children (B's EoS child)
def child(frames,tic,cx,cy,dx,dz,size,rng,dtic=1,**kw):
    tl=dtic if isinstance(dtic,list) else [dtic]*len(frames)
    ry=rng.uniform(.75,.9); g=rng.uniform(1.04,1.07); pre=[(g**min(i,5),ry) for i in range(sum(tl))]
    return L(frames,tl,start=tic,pos=(cx+dx*U,cy-dz*U),size=size,rot=rng.randint(0,359),presq=pre,**kw)
def pops(rng,cx,cy,size=60,start=0):
    st=strip('r276')[15].rotate(90,expand=True)
    a=rng.randint(0,359); out=[]
    for i in range(3):
        out.append(L([st],[3],start=start,pos=(cx,cy),size=size,rot=a,presq=[(1,.4),(.8,.55),(.7,.8)],
                     alist=[.8,.6,.3],ramp=R_SHOCK,gain=1.3,clip=True))
        a+=rng.randint(90,130)
    return out
# ------------------------------------------------------------------ shrapnel
HOT4=[(255,255,240),(255,232,130),(255,165,40),(190,60,0)]
HOT3=[(255,230,120),(255,140,20),(150,40,0)]
HOT2=[(255,140,30),(140,36,0)]
class Shrapnel:
    """hard pixel streaks. Each fragment: launch tic, angle, speed (map units/tic); drag .8 a tic, gravity; the streak is
    the path of its last tic, coloured in flat steps by speed (white head when fast). On the floor: a spark tick, a hot
    pepper mark that cools to a dark speck, and a low ricochet."""
    def __init__(s,cx,cy,n=44,seed=1,floor=True,vmax=50,start=0):
        r=random.Random(seed); s.f=[]; s.marks=[]; s.sparks=[]; s.start=start
        for i in range(n):
            if floor: ang=r.uniform(-6,186) if i%5 else r.choice([r.uniform(-6,10),r.uniform(170,186)])   # every 5th skims the floor
            else: ang=(i*360/n+r.uniform(-5,5))%360
            big=i%4==0
            v=r.uniform(.68,1.0)*vmax if (big or r.random()<.6) else r.uniform(.3,.55)*vmax
            d=dict(t0=r.choice([0,0,0,0,1,1,2]),a=math.radians(ang),v=v,big=big,dz=r.uniform(0,10),life=r.randint(9,14))
            if floor and i%2: p_=s.f[-1]; d=dict(p_,a=math.pi-p_['a'],v=p_['v']*r.uniform(.9,1.1),dz=r.uniform(0,10))   # mirrored pair: centred
            s.f.append(d)
        # integrate (sub-steps) to get per-tic positions
        s.path=[]
        for f in s.f:
            x,y=cx+math.cos(f['a'])*3*U,cy-math.sin(f['a'])*3*U; vx=math.cos(f['a'])*f['v']*U; vy=-math.sin(f['a'])*f['v']*U
            P=[(x,y,math.hypot(vx,vy)/U,False)]; hit=False
            for t in range(f['life']):
                bounced=False
                for k in range(4):
                    x+=vx/4; y+=vy/4; vy+=1.4*U/4
                    if floor and y>=FLOOR+f['dz']*.5 and vy>0:
                        y=FLOOR+f['dz']*.5; bounced=True
                        if not hit: s.marks.append((f['t0']+t+1,x,FLOOR+1+f['dz'],r.random()))
                        hit=True; vy=-abs(vy)*.3; vx*=.55
                    if not floor and y>=FLOOR and vy>0: y=FLOOR; vy=-abs(vy)*.3; vx*=.5; bounced=True; hit=True; s.marks.append((f['t0']+t+1,x,FLOOR+1+f['dz'],r.random()))
                vx*=.8; vy*=.8
                P.append((x,y,math.hypot(vx,vy)/U,bounced))
                if bounced and len([1 for q in P if q[3]])==1: s.sparks.append((f['t0']+t+1,x,y))
            s.path.append(P)
        s.len=max(f['t0']+len(P) for f,P in zip(s.f,s.path))+60
    def draw(s,c,t):
        t-=s.start
        for (tm,x,y,rv) in s.marks:          # floor pepper: hot -> cools to a dark speck that stays
            dt=t-tm
            if dt<0: continue
            if dt<2: col,w=(255,215,110),2
            elif dt<5: col,w=(255,120,20),2
            elif dt<9: col,w=(130,40,8),1
            else: col,w=(44,34,30),1
            add=dt<9
            px(c,x,y,kcol(col) if add else col,w,add)
            if dt<5: px(c,x-2,y,kcol((200,70,0)),1); px(c,x+2,y,kcol((200,70,0)),1)
        for (tm,x,y) in s.sparks:            # ricochet tick: tiny hard cross, 2 tics
            dt=t-tm
            if 0<=dt<2:
                col=kcol((255,250,200) if dt==0 else (255,170,40)); rr=3 if dt==0 else 2
                for k in range(-rr,rr+1): px(c,x+k,y-1,col); px(c,x,y-1+k,col)
        for f,P in zip(s.f,s.path):
            dt=t-f['t0']
            if dt<0 or dt+1>=len(P): continue
            x1,y1,v,_=P[dt+1]; x0,y0,_,_=P[dt]
            if v>25: cols=HOT4
            elif v>11: cols=HOT3
            elif v>4: cols=HOT2
            else: continue
            cols=[kcol(cc) for cc in cols]
            # streak: head at the new position, tail back along the last tic's path (at most 1 tic long)
            line(c,x1,y1,x0+(x1-x0)*.05,y0+(y1-y0)*.05,cols,1)
            if f['big'] and v>11: px(c,x1-1,y1-1,cols[0],2)
# ------------------------------------------------------------------ debris that bounces and settles (owner: #9's debris)
class Debris:
    """hard dark bits (casing, grit) thrown out; hot for a few tics, then dark; bounce on the floor plane (each at its own
    depth on it), slide, settle and stay."""
    def __init__(s,cx,cy,n=30,seed=2,cone=150,up=90,speed=(5,15),start=1,full=False):
        r=random.Random(seed); s.start=start; s.b=[]
        for i in range(n):
            if i%2==0: ang=math.radians(r.uniform(0,360) if full else up+r.uniform(-cone/2,cone/2)); v=r.uniform(*speed)*U
            else: ang=math.pi-ang; v*=r.uniform(.92,1.08)                      # mirrored pair: settles centred
            w,h=r.choice([(3,3),(4,3),(3,4),(4,4),(5,3),(3,2),(2,2)])
            dz=r.uniform(0,16); x,y=cx+r.uniform(-3,3)*U,cy+r.uniform(-3,3)*U; vx,vy=math.cos(ang)*v,-math.sin(ang)*v
            P=[]; rest=False; t0=start+r.choice([0,0,1])
            for t in range(140):
                if not rest:
                    x+=vx; y+=vy; vy+=1.1*U; vx*=.97
                    fy=FLOOR+dz-h
                    if y>=fy:
                        y=fy
                        if abs(vy)<2.2*U: rest=True; vy=0
                        else: vy=-abs(vy)*.42; vx*=.62
                P.append((x,y,rest))
            s.b.append((t0,P,w,h,r.choice([(96,84,74),(110,98,86),(84,76,72)])))
        s.len=200
    def draw(s,c,t):
        t-=s.start
        for t0,P,w,h,dark in s.b:
            dt=t-t0+s.start
            if dt<0: continue
            x,y,rest=P[min(dt,len(P)-1)]
            if dt<4: col=kcol((255,200,90)); add=True
            elif dt<8: col=kcol((230,100,25)); add=True
            elif dt<12: col=kcol((120,45,15)); add=True
            else: col=dark; add=False
            xi,yi=int(round(x)),int(round(y))
            if 0<=xi<CW-w and 0<=yi<CH-h:
                if add: c[yi:yi+h,xi:xi+w]+=np.array(col)
                else:
                    c[yi:yi+h,xi:xi+w]=col; c[yi,xi]=np.minimum(np.array(dark)+60,255)    # 1px top-left highlight
class Embers:
    """EoS BarrelFire: RSS0 pixel ember bits, 2 per tic for 7 tics, +-26 units, 16-32 up from the centre, thrown up"""
    def __init__(s,start,cx,cy,seed=1,scale=1.25,grav=1.0,n_tics=7,ramp_=None,gain=1.0,fall=False):
        rng=random.Random(seed); s.items=[]; s.cx=cx; s.cy=cy
        fr=strip('sparks/RSS0[A-D]0.png',None)
        for t in range(n_tics):
            r=rng.uniform(4,26)
            for sgn in (-1,1):
                if sgn<0: x0=rng.uniform(r*.6,r); z0=rng.uniform(16,32); vz0=rng.uniform(6,12)
                x=sgn*x0; z=z0; vz=vz0
                if fall: x=sgn*x0*2.6; z=z0-24; vz=vz0*.6          # bonus rain: spread wide, then fall
                tl=[rng.choice([2,3]) for _ in fr]; rot=rng.choice([0,90,180,270])
                s.items.append((start+t,x,z,vz,L(fr,tl,start=0,scale=scale,rot=rot,ramp=ramp_,gain=gain,clip=False,fade=.6)))
        s.grav=grav; s.start=start; s.len=max(st+it.len for st,_,_,_,it in s.items)-start
    def draw(s,c,t):
        for st,x,z,vz,it in s.items:
            tt=t-st
            if tt<0 or tt>=it.len: continue
            zz=z+vz*tt-0.5*s.grav*tt*tt
            y=s.cy-zz*U
            if y>FLOOR: continue
            it.pos=(s.cx+x*U,y); r=it.render(tt)
            if r: blit(c,*r,True)
class PixRing:
    """a hard pixel shock ring: radius eases out to R map units over dur tics; 3px white-hot -> 2px yellow -> 1px orange,
    breaking into dashes as it dies. squash<1 lays it flat on the floor. Air rings are cut at the floor line."""
    def __init__(s,cx,cy,R,start,dur,squash=1.0,floor_cut=True,r0=20,cols=None,dash=6):
        s.cx=cx; s.cy=cy; s.R=R; s.start=start; s.len=dur; s.sq=squash; s.cut=floor_cut; s.r0=r0; s.dash=dash
        s.cols=cols or [(255,255,235),(255,225,110),(255,150,30),(170,55,0)]
    def draw(s,c,t):
        dt=t-s.start
        if dt<0 or dt>=s.len: return
        k=dt/max(1,s.len-1); r=(s.r0+(s.R-s.r0)*(1-(1-k)**2.4))*U
        ci=min(len(s.cols)-1,int(k*len(s.cols))); col=kcol(s.cols[ci],.9); w=max(1,3-ci)
        n=int(2*math.pi*r)+8
        for i in range(n):
            a=2*math.pi*i/n
            if k>.55 and (i//s.dash)%2: continue
            if k>.8 and (i//s.dash)%4==2: continue
            x=s.cx+math.cos(a)*r; y=s.cy-math.sin(a)*r*s.sq
            if s.cut and y>FLOOR-w: continue
            px(c,int(x)-w//2,int(y)-w//2,col,w)
class Tracer:
    """the player's shot: a hard pixel tracer from off-screen right to the grenade, 2 tics"""
    def __init__(s,start,frm,to): s.start=start; s.a=frm; s.b=to; s.len=2
    def draw(s,c,t):
        dt=t-s.start
        if dt<0 or dt>=2: return
        (x0,y0),(x1,y1)=s.a,s.b
        if dt==0: hx,hy=x0+(x1-x0)*.55,y0+(y1-y0)*.55; tx,ty=x0,y0
        else: hx,hy=x1,y1; tx,ty=x0+(x1-x0)*.45,y0+(y1-y0)*.45
        line(c,hx,hy,tx,ty,[(255,255,230),(255,230,120),(255,170,40),(160,60,0)],1)
# ------------------------------------------------------------------ the frag blast
def frag(cx,cy,floor,rng,air_bonus=False):
    it=[]
    zc=(FLOOR-cy)/U
    # soot after: blocky Reactorcore grey puffs, darkened, rising (behind everything)
    for t0,dx,dz,sz,vy in [(6,-9,10,40,-0.8),(7,9,14,36,-0.9),(9,-3,26,42,-1.1),(12,3,36,38,-1.3),(15,0,46,34,-1.5)]:
        it.append(L(pick('rc_grey',range(3,11)),3,start=t0,pos=(cx+dx*U,cy-dz*U),size=sz,grow=.5,ramp=R_SOOT,gain=.75,
                    add=False,alpha=.8,vel=(0,vy),fade=.45,fadein=3,flip=rng.random()<.5,clip=floor))
    if floor:
        # ring 1: hot shock ring flat on the floor out to 200 units in ~6 tics; ring 2 (the second A_Explode) to 255
        it.append(PixRing(cx,FLOOR+2,200,1,8,squash=.12,floor_cut=False,r0=24))
        it.append(PixRing(cx,FLOOR+2,255,5,9,squash=.12,floor_cut=False,r0=60,cols=[(255,200,90),(255,140,20),(170,55,0)],dash=4))
        # grit puffs kicked up where the rings pass
        for k,(d,tt) in enumerate([(75,3),(-75,3),(135,5),(-135,5),(195,7),(-195,7),(240,9),(-240,9)]):
            it.append(L(pick('ruf_dust',[1,2,2]),[2,3,4],start=tt,pos=(cx+d*U,FLOOR-5),size=26+abs(d)*.05,
                        grow=.6,ramp=R_DUST,add=False,alpha=.85,fade=.5,clip=True,nokind=True,flip=k%2==1))
    else:
        # air: an upright shock ring out to 200 units, then a dashed orange one to 255 (cut at the floor)
        it.append(PixRing(cx,cy,200,1,8,r0=26))
        it.append(PixRing(cx,cy,255,4,9,r0=60,cols=[(255,200,90),(255,140,20),(170,55,0)],dash=4))
    # MAIN: 8-point star crack (1 tic) -> same star solid white (2 tics) -> white ball opening to a ring (Rufaswan)
    star=pick('ruf_star',[4])[0]; fl=pick('ruf_yflash',[5,6,7,8])
    it.append(L([star,star],[1,2],start=0,pos=(cx,cy),size=84,sil=(1,3),clip=floor,keepwhite=True))
    it.append(L(fl,[1,1,2,2],start=3,pos=(cx,cy),size=64,grow=.35,ease=2,clip=floor,fade=.6))
    # the second crack (tic 6, the second A_Explode): a smaller star turned 22.5 deg, 1 tic white, 2 tics hot
    it.append(L([star,star,star],[1,1,1],start=6,pos=(cx,cy),size=50,rot=22.5,sil=(0,1),ramp=R_GOLD,gain=.82,cool=.5,alist=[1,1,.6],clip=floor))
    # crack rays: the star's points thrown out as long hard lines (a frag's crack); tic 1-2 only
    it.append(Rays(cx,cy,start=1,floor=floor,rng=rng))
    it+=pops(rng,cx,(FLOOR-4*U) if floor else cy,size=70)
    # children: one per tic on tics 3,4,5, small and fast (1 tic a frame)
    for k,(dx,dz,sz) in enumerate([(-6,-4 if not floor else 6,42),(6,4 if not floor else 14,42),(0,10 if not floor else 22,34)]):
        it.append(child(pick('rc_ring',range(4,15)),3+k,cx,cy if not floor else FLOOR,dx,dz,sz,rng,dtic=[1]*8+[2]*3,fade=.7,clip=floor))
    it.append(Shrapnel(cx,cy-(2*U if floor else 0),seed=rng.randint(0,999),floor=floor))
    it.append(Debris(cx,cy-(3*U if floor else 0),seed=rng.randint(0,999),full=not floor,speed=(5,14) if floor else (4,12)))
    it.append(Embers(3,cx,cy if not floor else FLOOR,seed=rng.randint(0,999)))
    if air_bonus:
        # BONUS (skill shot): a gold crosshair ring locks on the burst, then a gold cluster ring pops at 120 units and
        # gold pixel embers rain down
        ch=strip('r276')[17]
        it.append(L([ch],[6],start=2,pos=(cx,cy),size=70,grow=1.4,ease=2,ramp=R_GOLD,gain=1.4,alist=[1,1,1,.8,.6,.4],clip=False))
        it.append(L(pick('ruf_cluster',[0,1,2,3,4]),[2,2,3,3,4],start=5,pos=(cx,cy),size=150,grow=.6,ease=2,ramp=R_GOLD,gain=1.2,fade=.6,clip=False))
        it.append(Embers(6,cx,cy,seed=rng.randint(0,999),ramp_=R_GOLD,gain=1.8,fall=True,n_tics=8,grav=.8))
    return it
class Rays:
    """the 8 star points flung out as hard lines (white tips, stepped to orange), 2 tics; on the floor only the upper five"""
    def __init__(s,cx,cy,start,floor,rng): s.cx=cx; s.cy=cy; s.start=start; s.floor=floor; s.len=2
    def draw(s,c,t):
        dt=t-s.start
        if dt<0 or dt>=2: return
        for k in range(8):
            a=math.radians(k*45+90)
            if s.floor and math.sin(a)<-.1: continue
            r0=(46 if dt==0 else 110)*U; r1=(120 if dt==0 else 190)*U
            cols=[kcol(cc) for cc in ([(255,255,240),(255,230,120),(255,160,40)] if dt==0 else [(255,170,40),(170,50,0)])]
            line(c,s.cx+math.cos(a)*r1,s.cy-math.sin(a)*r1,s.cx+math.cos(a)*r0,s.cy-math.sin(a)*r0,cols,2 if dt==0 else 1)
# ------------------------------------------------------------------ the shots
def run(items,pre,T0,tail,floorlight=None,actor=None,guide=False):
    end=max(getattr(i,'start',0)+min(i.len,40) for i in items)+tail
    frames=[]
    for t in range(-T0,end):
        c=background()
        if t>=0 and floorlight: floorlight(c,t)
        if actor: actor(c,t)
        for i in sorted(items,key=lambda i:getattr(i,'z',0)):
            if t<0 and not isinstance(i,Tracer): continue
            if hasattr(i,'draw'): i.draw(c,t); continue
            r=i.render(t)
            if r: blit(c,*r,i.add)
        if guide: c[:,BX]=c[:,BX]*.5+np.array([0,255,255])*.5
        frames.append(Image.fromarray(np.clip(c,0,255).astype(np.uint8)))
    return frames,T0
def floor_shot(seed=7,guide=False):
    rng=random.Random(seed); T0=72
    # throw in from the left: arc, two bounces, slide to a stop on BX
    x,y,vx,vy=0.0,FLOOR-130.0,8.5,-3.0; P=[]; rest=False; sliding=False
    for t in range(T0):
        if not rest:
            x+=vx
            if not sliding:
                y+=vy; vy+=.8
                if y>=FLOOR-4:
                    y=FLOOR-4
                    if vy<2.6: sliding=True; vy=0
                    else: vy=-vy*.35; vx*=.7
            else:
                vx*=.8; rest=abs(vx)<.15
        P.append((x,y,not sliding))
    sx=BX-P[-1][0]; P=[(px_+sx,py,air) for px_,py,air in P]
    on=fuse_schedule()
    def actor(c,t):
        if t>=0: return
        x,y,air=P[t+T0]
        im=TUMBLE[((t+T0)//2)%6] if air else REST
        nade_draw(c,im,x,y,'white' if t==-1 else blink_mode(t,on))
    items=frag(BX,Z(18),True,rng)
    fl=banded_glow(env(1.0,1,10),(255,150,60),w=round(400*U),h=36)
    return run(items,0,T0,10,fl,actor,guide)
def air_shot(seed=11,guide=False):
    rng=random.Random(seed); T0=56; cx,cy=BX,Z(120)
    vx,g=5.0,.3; vy0=(cy+.5*g*T0*T0-Z(36))/T0     # lands the arc on the blast point at tic 0
    on=fuse_schedule(gaps=(9,8,7,6,5,4))
    def pos(t): return cx+vx*t, cy+vy0*t+.5*g*t*t
    def actor(c,t):
        if t>=0: return
        x,y=pos(t)
        mode='white' if t>=-1 else blink_mode(t,on)
        nade_draw(c,TUMBLE[((t+T0)//2)%6],x,y,mode)
        if t==-1:   # HIT: a hard white-gold star ting where the round met the grenade (Rufaswan star, 1 tic)
            st=strip('ruf_star')[1]; st=st.resize((round(st.width*1.4),round(st.height*1.4)),Image.NEAREST)
            a=np.asarray(st).astype(float); al=(a[...,3]>127).astype(float); h,w=al.shape
            blit(c,a[...,:3],al,1.0,int(round(x-w/2)),int(round(y-h/2)),False)
            nade_draw(c,TUMBLE[((t+T0)//2)%6],x,y,'white')
    tx,ty=pos(-1)
    items=frag(cx,cy,False,rng,air_bonus=True)+[Tracer(-2,(CW+4,Z(30)),(tx,ty))]
    fl=banded_glow(env(.5,1,8),(255,150,60),w=round(380*U),h=30)
    return run(items,0,T0,10,fl,actor,guide)
def sheet(fr,T0,path,tics,crop=(40,40,600,420),scale=1,label=''):
    w=crop[2]-crop[0]; h=crop[3]-crop[1]
    S=Image.new('RGB',(len(tics)*w*scale,h*scale+14)); d=ImageDraw.Draw(S)
    for i,t in enumerate(tics):
        S.paste(fr[t+T0].crop(crop).resize((w*scale,h*scale),Image.NEAREST),(i*w*scale,14))
        d.text((i*w*scale+4,2),f'{label} tic {t:+d}',fill=(255,220,0))
    return S
if __name__=='__main__':
    guide='--guide' in sys.argv
    O='/tmp/fx_agentG/out'
    for name,fn in [('floor',floor_shot),('air',air_shot)]:
        fr,T0=fn(guide=guide)
        tag='_guide' if guide else ''
        for i,f in enumerate(fr): f.save(f'/tmp/fx_agentG/look/{name}{tag}_{i-T0:+04d}.png')
        if not guide:
            save_gif(fr,f'{O}/G_frag_{name}_full.gif',1); save_gif(fr,f'{O}/G_frag_{name}_half.gif',2)
        print(name,'frames',len(fr),'pre',T0,'blast tics',len(fr)-T0)
