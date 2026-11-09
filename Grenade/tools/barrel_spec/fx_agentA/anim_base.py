import os,glob,random
from PIL import Image, ImageChops
F='/tmp/eosfr'; O='/tmp/eosout'
def seq(k): return [Image.open(p).convert('RGBA') for p in sorted(glob.glob(f'{F}/{k}/*.png'))]
S={k:seq(k) for k in os.listdir(F)}
BG=(0,0,0,255); CW,CH=260,240; CX,CY=130,140
def fit(im,d):  # scale so max side = d
    s=d/max(im.size); return im.resize((max(1,int(im.width*s)),max(1,int(im.height*s))),Image.NEAREST)
def white(im):
    w=Image.new('RGBA',im.size,(255,255,255,0)); w.putalpha(im.split()[3]); return w
class Layer:
    def __init__(s,frames,start=0,size=150,rot=0,squash=1.0,dy=0,add=True,grow=None,fade=None):
        s.fr=frames; s.start=start; s.size=size; s.rot=rot; s.sq=squash; s.dy=dy; s.add=add; s.grow=grow; s.fade=fade
        s.len=sum(t for _,t in frames)
    def at(s,t):
        t-=s.start
        if t<0 or t>=s.len: return None
        acc=0
        for i,(im,d) in enumerate(s.fr):
            if t<acc+d: break
            acc+=d
        k=t/max(1,s.len-1)
        size=s.size*(1+(s.grow or 0)*k)
        im=fit(im,size)
        if s.rot: im=im.rotate(s.rot,expand=True,resample=Image.NEAREST)
        if s.sq!=1: im=im.resize((im.width,max(1,int(im.height*s.sq))),Image.NEAREST)
        if s.fade and k>s.fade:
            a=im.split()[3].point(lambda v:int(v*(1-(k-s.fade)/(1-s.fade)))); im.putalpha(a)
        return im
def render(layers,tail=8):
    T=max(l.start+l.len for l in layers)+tail; out=[]
    for t in range(T):
        c=Image.new('RGBA',(CW,CH),BG)
        for l in layers:
            im=l.at(t)
            if im is None: continue
            pos=(CX-im.width//2, CY-im.height//2+l.dy)
            if l.add:
                tmp=Image.new('RGBA',(CW,CH),(0,0,0,0)); tmp.paste(im,pos,im)
                r,g,b,al=tmp.split()
                pm=Image.merge('RGB',[ImageChops.multiply(ch,al) for ch in (r,g,b)])
                c=Image.merge('RGBA',(*ImageChops.add(c.convert('RGB'),pm).split(),Image.new('L',(CW,CH),255)))
            else: c.alpha_composite(im,pos)
        out.append(c.convert('RGB'))
    return out
def save(frames,name,slow=1,label=None):
    fr=[f.resize((CW*2,CH*2),Image.NEAREST) for f in frames]
    fr[0].save(f'{O}/{name}.gif',save_all=True,append_images=fr[1:],duration=int(1000/35*slow),loop=0)
def L(k,tics,**kw):
    fr=S[k]; tl=tics if isinstance(tics,list) else [tics]*len(fr)
    return Layer(list(zip(fr,tl)),**kw)
# recipes
def flashpop(rot=0,sc=1.0,start=0):
    d=S['domes'][1]
    return [Layer([(d,1),(white(d),2)],start=start,size=140*sc,rot=rot),
            L('rf_yring',2,start=start+3,size=150*sc,grow=0.25,fade=0.5)]
def hollow(rot=0,sc=1.0,start=0):
    return [L('domes',[1,2,2,2,3],start=start,size=150*sc,rot=rot),
            L('f2ring',[6],start=start+10,size=170*sc,grow=0.3,fade=0.2,rot=rot)]
def hollow_alt(rot=0,sc=1.0,start=0):
    return [L('rf_firering',2,start=start,size=150*sc,rot=rot)]
def cvcore(rot=0,sc=1.0,start=0):
    return [L('cv4',[1,2,2,2,2,2,3,3],start=start,size=150*sc,rot=rot)]
def shock(start=0,sc=1.0):
    return [L('rf_yring',2,start=start+1,size=170*sc,squash=0.3,dy=55,grow=0.6,fade=0.4,add=True)]
def rccore(rot=0,sc=1.0,start=0):
    return [L('rc_ring',2,start=start,size=170*sc,rot=rot)]
def smoke(start=0,sc=1.0):
    return [L('rc_red',[2]*12,start=start,size=120*sc,add=False,dy=-5),
            L('rc_grey',[3]*16,start=start+8,size=150*sc,add=False,dy=-15,fade=0.6)]
if __name__=='__main__':
    save(render(flashpop()),'1_flash_pop_half',slow=2)
    save(render(hollow()),'2_hollow_out_half',slow=2)
    save(render(rccore()+shock()),'3_shockwave_half',slow=2)
    save(render(cvcore()+smoke(start=10)),'4_dirty_finish_half',slow=2)
    random.seed(7); reel=[]
    cores=[flashpop,hollow,hollow_alt,cvcore,rccore]
    for i in range(10):
        c=random.choice(cores); rot=random.choice([0,90,180,270]); sc=random.uniform(0.85,1.15)
        ls=c(rot=rot,sc=sc)
        if random.random()<0.5: ls+=shock(sc=sc)
        if random.random()<0.5: ls+=smoke(start=8,sc=sc)
        reel+=render(ls,tail=6)
    save(reel,'5_random_reel_fullspeed',slow=1)
    print('ok')
