"""Set A compositor: layers in tics, additive/normal blend, floor, barrel, sparks. Extends anim_base.py ideas."""
import math, random, numpy as np
from PIL import Image, ImageDraw
import assets as A, kvx
CW=CH=320; FY=262; BX=160; PX=1.25          # px per map unit; barrel 42u -> ~52px
BH=int(42*PX)
POS={'B':(BX,FY-3),'M':(BX,FY-BH//2),'T':(BX,FY-BH)}
def xform(im,scale,rot=0,flip=False,squash=1.0):
    w=max(1,round(im.width*scale)); h=max(1,round(im.height*scale*squash))
    im=im.resize((w,h),Image.NEAREST)
    if flip: im=im.transpose(Image.FLIP_LEFT_RIGHT)
    if rot%360: im=im.rotate(rot,expand=True,resample=Image.NEAREST)
    return im
class Layer:
    """frames=[(img,tics)...]; scale is a multiplier on source px (same for every frame of a strip);
    size= alternative: largest frame's max side in px. anchor 'c' centre or 'b' bottom of the frame canvas."""
    def __init__(s,frames,start,pos,scale=None,size=None,rot=0,flip=False,squash=1.0,add=True,alpha=1.0,
                 grow=0.0,fade=None,fadein=0,vel=(0,0),acc=(0,0),anchor='c',floor=False,gain=1.0,name='',z=0):
        s.fr=frames; s.start=start; s.pos=pos; s.rot=rot; s.flip=flip; s.sq=squash; s.add=add; s.alpha=alpha
        s.grow=grow; s.fade=fade; s.fadein=fadein; s.vel=vel; s.acc=acc; s.anchor=anchor; s.floor=floor; s.gain=gain; s.name=name; s.z=z
        if scale is None: scale=size/max(max(im.size) for im,_ in frames)
        s.scale=scale; s.len=sum(t for _,t in frames)
    def end(s): return s.start+s.len
    def at(s,t):
        t-=s.start
        if t<0 or t>=s.len: return None
        acc=0
        for im,d in s.fr:
            if t<acc+d: break
            acc+=d
        k=t/max(1,s.len-1)
        img=xform(im,s.scale*(1+s.grow*k),s.rot,s.flip,s.sq)
        a=s.alpha
        if s.fade is not None and k>s.fade: a*=max(0,1-(k-s.fade)/(1-s.fade+1e-9))
        if s.fadein and t<s.fadein: a*=(t+1)/(s.fadein+1)
        x=s.pos[0]+s.vel[0]*t+0.5*s.acc[0]*t*t; y=s.pos[1]+s.vel[1]*t+0.5*s.acc[1]*t*t
        ox=x-img.width/2; oy=(y-img.height) if s.anchor=='b' else (y-img.height/2)
        return img,int(round(ox)),int(round(oy)),a
def blit(c,img,ox,oy,a,add,gain=1.0):
    arr=np.asarray(img).astype(np.float32)/255.
    x0,y0=max(0,ox),max(0,oy); x1,y1=min(CW,ox+img.width),min(CH,oy+img.height)
    if x1<=x0 or y1<=y0: return
    sub=arr[y0-oy:y1-oy,x0-ox:x1-ox]; al=sub[...,3:4]*a
    if add: c[y0:y1,x0:x1]+=sub[...,:3]*al*gain
    else: c[y0:y1,x0:x1]=c[y0:y1,x0:x1]*(1-al)+sub[...,:3]*al
class Sparks:
    """n sparks spawned evenly over `over` tics, thrown upward in a cone; gravity; short trails; additive."""
    def __init__(s,start,pos,n=14,over=7,spd=(3,6),cone=60,up=90,grav=0.35,life=(10,18),seed=1,sprite=None,size=7,trail=3,spread=6):
        r=random.Random(seed); s.p=[]; s.start=start
        spr=sprite or A.cfx('sparks','RSS0',['S'])[0].crop((6,5,28,28))
        s.spr=spr.resize((size,size),Image.NEAREST); s.small=spr.resize((max(2,size//2),)*2,Image.NEAREST)
        for i in range(n):
            ang=math.radians(up+r.uniform(-cone/2,cone/2)); v=r.uniform(*spd)
            s.p.append(dict(t0=start+int(i*over/n),x=pos[0]+r.uniform(-spread,spread),y=pos[1]+r.uniform(-spread/2,spread/2),
                            vx=v*math.cos(ang),vy=-v*math.sin(ang),life=r.randint(*life)))
        s.grav=grav; s.trail=trail
    def end(s): return max(p['t0']+p['life'] for p in s.p)
    def draw(s,c,t):
        for p in s.p:
            dt=t-p['t0']
            if dt<0 or dt>=p['life']: continue
            a=1.0 if dt<p['life']*0.6 else 1-(dt-p['life']*0.6)/(p['life']*0.4)
            for k in range(s.trail,-1,-1):
                tt=max(0,dt-k*0.5)
                x=p['x']+p['vx']*tt; y=p['y']+p['vy']*tt+0.5*s.grav*tt*tt
                im=s.spr if k==0 else s.small
                blit(c,im,int(x-im.width/2),int(y-im.height/2),a*(1 if k==0 else 0.45/k),True)
_barrel=None
def barrel():
    global _barrel
    if _barrel is None:
        V,pal=kvx.load('/home/claude/rsq_ubqseries/Monsters/voxels/BAR1A.kvx')
        W=V[:, ::-1, :]   # view along y from the far side (best lit face)
        xs,ys,zs=W.shape; img=np.zeros((zs,xs,4),np.uint8)
        for x in range(xs):
            for z in range(zs):
                col=W[x,:,z]; idx=np.where(col>=0)[0]
                if len(idx): img[z,x,:3]=pal[col[idx[0]]]; img[z,x,3]=255
        im=Image.fromarray(img); s=BH/im.height
        _barrel=im.resize((round(im.width*s),BH),Image.NEAREST)
    return _barrel
def barrel_layers(t_blast,blinks=4,idle=8):
    """barrel idles, then blinks hot (1 tic white-orange, 1 tic normal) and vanishes at t_blast"""
    b=barrel(); hot=A.tint([b],(2.2,1.5,0.9))[0]; wh=A.white(b)
    seq=[(b,idle)]
    for i in range(blinks): seq+=[(hot if i<blinks-1 else wh,1),(b,1)]
    t0=t_blast-sum(d for _,d in seq)
    return [Layer(seq,t0,(BX,FY),scale=1,add=False,anchor='b',name='barrel')]
def render(layers,sparks=(),T=None,light=None,pause=14):
    T=T or max([l.end() for l in layers]+[s.end() for s in sparks])+pause
    out=[]
    for t in range(T):
        c=np.zeros((CH,CW,3),np.float32); c[:]=(0.035,0.03,0.04)
        # floor plane + light pool
        c[FY:]=(0.07,0.065,0.07)
        L=light(t) if light else 0
        if L>0:
            yy,xx=np.mgrid[FY:CH,0:CW]; d=((xx-BX)/150.)**2+((yy-FY)/40.)**2
            c[FY:]+=np.exp(-d*2)[...,None]*np.array([1.0,0.55,0.2])*L*0.6
            yy,xx=np.mgrid[0:FY,0:CW]; d=((xx-BX)/170.)**2+((yy-FY+40)/140.)**2
            c[:FY]+=np.exp(-d*2)[...,None]*np.array([1.0,0.5,0.15])*L*0.12
        c[FY:FY+1]=np.maximum(c[FY:FY+1],(0.32,0.30,0.30))
        for l in sorted(layers,key=lambda l:l.z):
            if l.floor: continue
            r=l.at(t)
            if r: blit(c,*r,l.add,l.gain)
        for s in sparks: s.draw(c,t)
        for l in layers:
            if not l.floor: continue
            r=l.at(t)
            if r: blit(c,*r,l.add,l.gain)
        out.append(Image.fromarray((np.clip(c,0,1)*255).astype(np.uint8)))
    return out
def save(frames,path,slow=1):
    fr=[f.resize((CW*2,CH*2),Image.NEAREST).quantize(255,method=Image.MEDIANCUT,dither=Image.NONE) for f in frames]
    pat=[30,30,30,30,30,30,20] if slow==1 else [60,60,60,60,60,50,50]   # GIF has 10ms steps: averages 28.57 / 57.14 ms = 35 / 17.5 fps
    dur=[pat[i%7] for i in range(len(fr))]
    fr[0].save(path,save_all=True,append_images=fr[1:],duration=dur,loop=0,optimize=False,disposal=1)
