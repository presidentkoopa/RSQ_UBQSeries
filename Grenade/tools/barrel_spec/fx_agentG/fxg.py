# Agent G compositor for the GRENADE. Copied (not imported) from /tmp/fx_agentB/fx.py + fx_v2.py and extended:
# wider canvas so the 200/255-unit damage reach fits at the barrel scale; a global per-kind gradient map (KIND_LUT);
# hard pixel shrapnel streaks; bouncing debris that settles; floor pepper marks. Nearest-neighbour only, 1-bit alpha.
import os,glob,math,random
import numpy as np
from PIL import Image,ImageDraw
CF='/home/claude/rsq_ubqseries/Monsters/sprites/combatfx'
CW,CH=640,420; FLOOR=360; BX=320; U=1.25          # px per map unit (barrel set: 1.25-1.6)
def Z(z): return FLOOR-z*U
_cache={}
def _files(key):
    if os.path.isdir(f'/tmp/eosfr/{key}'): return sorted(glob.glob(f'/tmp/eosfr/{key}/*.png'))
    if os.path.isdir(f'/tmp/fx_agentB/cut/{key}'): return sorted(glob.glob(f'/tmp/fx_agentB/cut/{key}/*.png'))
    return sorted(glob.glob(f'{CF}/{key}'),key=lambda p:os.path.basename(p)[:6].upper())
def centre(im,mode='cent'):
    """B's re-centring: pad so the alpha-weighted centroid sits at the image centre (before any rotation)."""
    a=np.asarray(im); al=a[...,3]
    ys,xs=np.nonzero(al>8)
    if len(xs)==0: return im
    if mode=='bbox': return im.crop((xs.min(),ys.min(),xs.max()+1,ys.max()+1))
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
# ---- ramps ----
def ramp(*stops):
    xs=[p for p,_ in stops]; cs=np.array([c for _,c in stops],float)
    t=np.linspace(0,1,256); return np.stack([np.interp(t,xs,cs[:,i]) for i in range(3)],1)
R_HOT=ramp((0,(40,0,0)),(.35,(170,30,0)),(.6,(255,120,10)),(.82,(255,220,90)),(1,(255,255,235)))
R_SHOCK=ramp((0,(30,10,0)),(.4,(200,90,20)),(.7,(255,200,120)),(1,(255,250,240)))
R_DUST=ramp((0,(20,16,12)),(.5,(85,72,58)),(.8,(140,122,98)),(1,(185,170,145)))
R_SOOT=ramp((0,(14,12,11)),(.45,(58,50,44)),(.8,(104,94,84)),(1,(150,140,128)))
R_GOLD=ramp((0,(30,10,0)),(.4,(170,90,0)),(.7,(255,200,40)),(1,(255,255,220)))
def lum(a): return (a[...,0]*.3+a[...,1]*.59+a[...,2]*.11)/255.
# ---- per-kind gradient map (kinds.zs Colour(); -1 = the frag's own fire) ----
KINDS=[('Frag',None),('Impact',0xFF7814),('Incendiary',0xFFC828),('Freeze',0x46BEFF),('Stun',0xAA50FF),
       ('Smoke',0x8C8C96),('Flash',0xFFFFFF),('Charm',0xFF6EBE),('Infight',0x3CDC5A)]
def kind_ramp(hexc):
    c=np.array([(hexc>>16)&255,(hexc>>8)&255,hexc&255],float); w=np.array([255.,255,255])
    if hexc==0xFFFFFF:   # Flash: cold steel up to white
        return ramp((0,(6,6,10)),(.3,(60,64,84)),(.6,(160,166,190)),(.82,(225,230,245)),(1,(255,255,255)))
    return ramp((0,tuple(c*.03)),(.3,tuple(c*.35)),(.6,tuple(c*.85)),(.8,tuple(c*.55+w*.45)),(.93,tuple(c*.2+w*.8)),(1,(255,255,255)))
KIND_LUT=None; KIND_COL=None; RECENTRE=True
def kmap(rgb,top=1.0):
    """gradient-map an rgb array by brightness onto the kind's ramp; pure white stays white when top=1 (the flash);
    everything after the flash maps with top=.9 so the kind's colour shows in the body of the blast"""
    if KIND_LUT is None: return rgb
    p=np.clip(lum(rgb),0,1)*top; return KIND_LUT[(p*255).astype(int)]
def kcol(col,top=1.0):
    return tuple(kmap(np.array([[col]],float),top)[0,0]) if KIND_LUT is not None else col
class L:
    """sprite layer (B's fx_v2.L): pos canvas px; nearest scaling; hard 1-bit alpha; presq per-tic pre-roll squash."""
    def __init__(s,frames,tics,start=0,pos=(BX,FLOOR),size=None,scale=None,grow=0.0,rot=0,flip=False,squash=1.0,
                 ramp=None,cool=0.0,bright=1.0,add=True,alpha=1.0,fade=None,fadein=0,vel=(0,0),acc=(0,0),spin=0,
                 sil=0,silcol=(255,255,255),anchor='c',ease=1.0,gain=1.0,xs=1.0,clip=None,presq=None,alist=None,nokind=False,z=0,keepwhite=False):
        s.fr=frames; s.tl=tics if isinstance(tics,list) else [tics]*len(frames)
        assert len(s.tl)==len(s.fr),(len(s.tl),len(s.fr))
        s.start=start; s.pos=pos; s.grow=grow; s.rot=rot; s.flip=flip; s.sq=squash; s.ramp=ramp; s.cool=cool
        s.bright=bright; s.add=add; s.alpha=alpha; s.fade=fade; s.fadein=fadein; s.spin=spin
        s.sil=sil; s.silcol=np.array(silcol,float); s.anchor=anchor; s.ease=ease; s.gain=gain; s.xs=xs
        s.clip=(squash>=.5) if clip is None else clip; s.presq=presq; s.alist=alist; s.nokind=nokind; s.z=z; s.keepwhite=keepwhite
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
        rgb=a[...,:3]; al=(a[...,3]>127).astype(float)
        if s.sil and s.sil[0]<=tt<s.sil[1]: rgb=np.broadcast_to(s.silcol,rgb.shape).copy()
        elif s.ramp is not None:
            p=np.clip(lum(a)*s.gain*(1-s.cool*k),0,1); rgb=s.ramp[(p*255).astype(int)]
        if not s.nokind: rgb=kmap(rgb,1.0 if s.keepwhite else .9)
        m=s.alpha*s.bright
        if s.alist: m*=s.alist[min(tt,len(s.alist)-1)]
        if s.fade is not None and k>s.fade: m*=max(0,1-(k-s.fade)/(1-s.fade+1e-9))
        if s.fadein and tt<s.fadein: m*=(tt+1)/(s.fadein+1)
        x=s.pos[0]+s.vel[0]*tt+0.5*s.acc[0]*tt*tt; y=s.pos[1]+s.vel[1]*tt+0.5*s.acc[1]*tt*tt
        h,w=al.shape
        ox=int(round(x-w/2)); oy=int(round(y-(h if s.anchor=='b' else h/2)))
        if s.anchor=='c' and RECENTRE and al.any():
            # re-centre AFTER scaling/rotation: the art's alpha-weighted centre lands on the layer's position
            ys,xs=np.nonzero(al); ox=int(round(x-xs.mean()-.5)); oy=int(round(y-ys.mean()-.5))
        if s.clip:
            cut=int(FLOOR+1-oy)
            if cut<h: al=al.copy(); al[max(0,cut):]=0
        return rgb,al,m,ox,oy
def blit(c,rgb,al,m,ox,oy,add):
    h,w=al.shape
    x0,y0=max(0,ox),max(0,oy); x1,y1=min(CW,ox+w),min(CH,oy+h)
    if x1<=x0 or y1<=y0: return
    r=rgb[y0-oy:y1-oy,x0-ox:x1-ox]; a=(al[y0-oy:y1-oy,x0-ox:x1-ox]*m)[...,None]
    if add: c[y0:y1,x0:x1]+=r*a
    else: c[y0:y1,x0:x1]=c[y0:y1,x0:x1]*(1-np.clip(a,0,1))+r*np.clip(a,0,1)
def px(c,x,y,col,sz=1,add=True,a=1.0):
    xi,yi=int(round(x)),int(round(y))
    if 0<=xi and xi+sz<=CW and 0<=yi and yi+sz<=CH:
        if add: c[yi:yi+sz,xi:xi+sz]+=np.array(col)*a
        else: c[yi:yi+sz,xi:xi+sz]=c[yi:yi+sz,xi:xi+sz]*(1-a)+np.array(col)*a
def line(c,x0,y0,x1,y1,cols,w=1,add=True):
    """hard pixel line from head (x0,y0) back to (x1,y1); colours stepped along it in len(cols) flat bands"""
    n=int(max(abs(x1-x0),abs(y1-y0)))+1
    for i in range(n):
        f=i/max(1,n-1); x=x0+(x1-x0)*f; y=y0+(y1-y0)*f
        col=cols[min(len(cols)-1,int(f*len(cols)))]
        px(c,x,y,col,w,add)
# ---- background (B's) ----
def background():
    c=np.zeros((CH,CW,3)); c[:]=(8,8,12)
    c[FLOOR+1:]=(16,15,18)
    for i in range(1,8):
        y=FLOOR+1+int(i*i*1.3)
        if y<CH: c[y,:]=(24,23,27)
    c[FLOOR,:]=(70,68,76)
    return c
def banded_glow(env,col,w,h,cx=BX,bands=(1.0,.55,.25),p=2):
    """floor light: a few flat stepped bands on a 2px grid (stands in for a dynamic light)"""
    yy,xx=np.mgrid[0:CH,0:CW]
    xq=(xx//p)*p+p/2; yq=(yy//p)*p+p/2
    d=((xq-cx)/(w/2))**2+((yq-FLOOR)/(h/2))**2
    lv=np.zeros((CH,CW)); nb=len(bands)
    for i,b in enumerate(bands):
        lv[(d<(i+1)/nb)&(lv==0)]=b
    lv[:FLOOR]=0; lv[FLOOR]=lv[FLOOR+1]
    def f(c,t):
        e=env(t)
        if e>0: c+=lv[...,None]*np.array(kcol(col))*e
    return f
def env(peak=1.0,attack=1,decay=20,start=0,steps=4):
    def e(t):
        t-=start
        if t<0: return 0
        v=peak*(t+1)/attack if t<attack else peak*max(0,1-(t-attack)/decay)**1.6
        return math.ceil(v*steps)/steps if v>0 else 0
    return e
def save_gif(frames,path,slow=1):
    fr=[f.resize((CW*2,CH*2),Image.NEAREST) for f in frames]
    pat=[30,30,30,30,30,30,20] if slow==1 else [60,60,60,50,60,60,50]   # 35 / 17.5 fps
    dur=[pat[i%7] for i in range(len(fr))]
    q=[f.quantize(256,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE) for f in fr]
    q[0].save(path,save_all=True,append_images=q[1:],duration=dur,loop=0,disposal=1)
