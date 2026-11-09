"""v2: owner pixel rule + EoS barrel-death structure. #5 Snap, #6 Heavy, #7 Pillar."""
import sys, random; sys.path.insert(0,'/tmp/fx_ctx1/a')
import assets as A, fx
from fx import Layer, PixSparks, BX, FY, PX
fx.OCC=True
T0=18
U=lambda u: u*PX                       # map units -> px
CEN=(BX,FY-U(24))                      # EoS: Explosm spawned 24 units up
def strip(frames,tics):
    tl=tics if isinstance(tics,list) else [tics]*len(frames); return list(zip(frames,tl))
def solid(im,col=(255,255,255)):
    w=A.white(im); return A.tint([w],tuple(c/255 for c in col))[0]
# ---- pixel art only ----
DOMES=A.gmap(A.circ(A.eos('domes')[1:]),'fire',gamma=0.7)
F2RING=A.eos('f2ring'); YRING=A.eos('rf_yring'); RCRING=A.eos('rc_ring'); FIRERING=A.eos('rf_firering')
RC4=A.rc_sheet(4); RC3=A.rc_sheet(3); RCRED=A.eos('rc_red'); RCGREY=A.eos('rc_grey')
SMOKE=A.tint(RCGREY,(0.42,0.40,0.40))          # rc_grey darkened for after-smoke
BUB=A.gmap(A.ruf_cells(1163,1220,[0,40,92,142,192,245,297,349,401,453,505,556,612]),'fire')
PRING=A.gmap(A.ruf_cells(1300,1356,[227,248,280,320,370,420,473,527,580]),'fire',lo=90,hi=250)
YPUFF=A.ruf_cells(369,424,[0,22,52,100,152,206,257,307,365])
_r=A.ruf()
from PIL import Image
STREAK=A.clean(Image.fromarray(_r[280:297,414:457].copy()),3)     # Rufaswan yellow flash streak (pixel)
POPK=[(1.0,0.4),(0.8,0.55),(0.7,0.8)]                              # EoS ExplosionPop scale keys, 1 tic each
def pops(t,r,scale=2.2,y=None):
    """three flat light pops at the base, same tic, angles ~100-130 deg apart, alpha .8 fading"""
    a=r.randrange(360); out=[]
    for i in range(3):
        out.append(Layer([(STREAK,3)],t,(BX,y or FY-U(16)),scale=scale,rot=a,keyframes=POPK,alpha=0.8,fade=0.3,name=f'pop{i}'))
        a+=r.randint(90,130)
    return out
def child_pos(r,band):
    """ExplosmChild: random spot within 12 units of the main blast; biased bottom/mid/top of the barrel"""
    dz={'B':(-12,-6),'M':(-3,3),'T':(6,12)}[band]
    return (CEN[0]+U(r.uniform(-12,12)),CEN[1]-U(r.uniform(*dz)))
def light(pts):
    import numpy as np
    return lambda t: float(np.interp(t,[p[0] for p in pts],[p[1] for p in pts],left=0,right=0))
# ===================== #5 SNAP =====================
def snap():
    r=random.Random(11); L=fx.barrel_layers_eos(T0)
    # main blast: Reactorcore ring flash (rc_ring). EoS order: big frame 1 tic, 2-tic solid silhouette, then the strip from the start
    rot=r.randrange(360)
    L+=[Layer([(RCRING[3],1),(solid(RCRING[3]),2)]+strip(RCRING[2:],1),T0,CEN,scale=2.0,rot=rot,name='main rc_ring')]
    L+=pops(T0,r,scale=3.0)
    L+=[Layer(strip(YRING[1:],[1,1,1,2,2,2,2]),T0+1,(BX,FY),size=110,squash=0.28,grow=0.7,fade=0.55,floor=True,name='floor ring')]
    # children on main tics 3,4,5 (first three normal-render tics): bottom / mid / top, yellow-brown pixel fireballs
    for i,b in enumerate('BMT'):
        L+=[Layer(strip(RC4[2:],[1]*8+[2]*6),T0+3+i,child_pos(r,b),scale=r.uniform(1.8,2.3),rot=r.randrange(360),
                  sxg=r.uniform(1.04,1.08),squash=r.uniform(0.8,1.0),name=f'child {b}')]
    S=[PixSparks(T0+3,per=2,tics=7,seed=3,scale=2)]
    L+=[Layer(strip(SMOKE[4:],2),T0+13,(BX+2,CEN[1]-U(14)),scale=2.2,add=False,alpha=0.85,vel=(0,-0.7),fadein=3,fade=0.5,z=-1,name='smoke rc_grey')]
    return L,S,light([(T0-1,0),(T0,1),(T0+4,0.8),(T0+14,0.2),(T0+20,0)])
# ===================== #6 HEAVY =====================
def heavy():
    r=random.Random(23); L=fx.barrel_layers_eos(T0)
    rot=r.randrange(360)
    # main: fx_sheet_2 big circular blast, gradient-mapped hot white->yellow->orange; silhouette in hot yellow
    L+=[Layer([(DOMES[1],1),(solid(DOMES[1],(255,244,170)),2)]+strip(DOMES,[1,2,2,3]),T0,CEN,size=150,rot=rot,name='main domes'),
        Layer(strip(PRING[3:],[2,2,3,3,4]),T0+5,CEN,scale=3.4,grow=0.4,fade=0.6,name='main cap rings (Rufaswan pastel->fire)')]
    L+=pops(T0,r,scale=3.8)
    L+=[Layer(strip(F2RING,[14]),T0+2,(BX,FY),size=130,squash=0.26,grow=1.3,fade=0.35,floor=True,name='floor f2ring')]
    # children: fat pixel fireballs replacing the old RSI0/RSE1
    L+=[Layer(strip(RC4[3:],[1]*6+[2]*7),T0+3,child_pos(r,'B'),scale=4.0,rot=r.randrange(360),sxg=1.03,name='child B rc4'),
        Layer(strip(FIRERING,[1,1,2,2,2,2,3,3,3]),T0+4,child_pos(r,'M'),scale=3.2,rot=r.randrange(360),sxg=1.03,name='child M rf_firering'),
        Layer(strip(BUB[2:],[1,1,2,2,2,2,3,3,3,3]),T0+5,child_pos(r,'T'),scale=2.4,rot=r.randrange(360),name='child T bubble burst')]
    # heavy body: Reactorcore red fireball breaking into dark smoke, then darkened grey puff
    L+=[Layer(strip(RCRED,[2,2,2,2,3,3,3,3,3,3,3,3]),T0+8,(BX-4,CEN[1]-U(10)),scale=4.2,add=False,rot=r.choice([0,90,180,270]),fadein=2,z=-1,name='body rc_red'),
        Layer(strip(SMOKE[6:],3),T0+22,(BX+6,CEN[1]-U(34)),scale=3.6,add=False,alpha=0.85,vel=(0,-0.5),fadein=5,fade=0.5,z=-2,name='smoke rc_grey')]
    S=[PixSparks(T0+3,per=3,tics=7,seed=5,vz=(7,13),scale=2.2)]
    return L,S,light([(T0-1,0),(T0,1),(T0+8,1),(T0+22,0.5),(T0+40,0)])
# ===================== #7 PILLAR =====================
def pillar():
    r=random.Random(37); L=fx.barrel_layers_eos(T0)
    rot=r.randrange(360)
    # main: Rufaswan yellow flash ring (pale ball -> ring), silhouette in white
    L+=[Layer([(YRING[0],1),(solid(YRING[0]),2)]+strip(YRING,[1,1,1,2,2,2,2,2]),T0,CEN,scale=2.4,rot=rot,name='main rf_yring')]
    L+=pops(T0,r,scale=3.0)
    L+=[Layer(strip(YRING[2:],[1,1,2,2,2,3]),T0+1,(BX,FY),size=110,squash=0.26,grow=0.8,fade=0.5,floor=True,name='floor ring')]
    for i,b in enumerate('BMT'):
        L+=[Layer(strip(YPUFF[1:],[1,1,2,2,2,2,3]),T0+3+i,child_pos(r,b),scale=r.uniform(1.4,1.7),rot=r.randrange(360),name=f'child {b} yellow puff')]
    # the pillar: stacked pixel blasts climbing from the barrel top, one every 2 tics, each a little smaller,
    # plus a vertically stretched (nearest) rc4 fireball as the column core
    y=FY-U(42); sc=2.6
    for k in range(9):
        y-=U(12)-k*0.8; x=BX+U(r.uniform(-5,5))
        src=RC4[3:] if k%2==0 else YPUFF[2:]
        tl=[1]*6+[2]*7 if k%2==0 else [1,2,2,2,2,3]
        L+=[Layer(strip(src,tl),T0+4+int(1.5*k),(x,y),scale=sc if k%2==0 else sc*0.62,rot=r.randrange(360),name=f'column blast {k}')]
        sc*=0.92
    L+=[Layer(strip(FIRERING[1:],[2,2,2,2,2,3,3,3]),T0+18,(BX,y-U(4)),size=90,squash=0.35,vel=(0,-1.6),grow=0.9,fade=0.5,name='crown rf_firering')]
    L+=[Layer(strip(RCRED[3:],[2,2,3,3,3,3,3,3,3]),T0+20,(BX,y-U(14)),scale=2.6,add=False,vel=(0,-0.8),fade=0.6,z=-1,name='top rc_red to smoke'),
        Layer(strip(SMOKE[6:],3),T0+28,(BX,y-U(30)),scale=2.6,add=False,alpha=0.8,vel=(0,-0.6),fadein=4,fade=0.5,z=-2,name='smoke rc_grey')]
    S=[PixSparks(T0+3,per=2,tics=7,seed=8,spread=14,vz=(9,14),vx=0.3,scale=2)]
    return L,S,light([(T0-1,0),(T0,1),(T0+6,0.8),(T0+24,0.6),(T0+40,0)])
SEQS=[('5_snap',snap),('6_heavy',heavy),('7_pillar',pillar)]
if __name__=='__main__':
    O='/tmp/fx_ctx1/look/out'; which=sys.argv[1:] or [n for n,_ in SEQS]
    for name,fn in SEQS:
        if name not in which: continue
        Ls,Ss,lt=fn(); fr=fx.render(Ls,Ss,light=lt)
        fx.save(fr,f'{O}/A1_{name}_v2_full.gif'); fx.save(fr,f'{O}/A1_{name}_v2_half.gif',slow=2)
        [f.save(f'/tmp/fx_ctx1/look/look/{name}v2_{i:03d}.png') for i,f in enumerate(fr)]
        print(name,len(fr),'blast tics',max([l.end() for l in Ls]+[s.end() for s in Ss])-T0)
