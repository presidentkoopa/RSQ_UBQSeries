import sys, random; sys.path.insert(0,'/tmp/fx_agentA')
import assets as A, fx
from fx import Layer, Sparks, POS, BX, FY, BH
from PIL import Image, ImageDraw
T0=16   # blast tic (barrel idles 8, blinks 8)
def strip(frames,tics):
    tl=tics if isinstance(tics,list) else [tics]*len(frames); return list(zip(frames,tl))
# ---------------- shared art ----------------
DOMES=A.eos('domes'); F2RING=A.eos('f2ring'); YRING=A.eos('rf_yring'); RCRING=A.eos('rc_ring'); FIRERING=A.eos('rf_firering')
RC4=A.rc_sheet(4); RC3=A.rc_sheet(3)
BUB=A.gmap(A.ruf_cells(1163,1220,[0,40,92,142,192,245,297,349,401,453,505,556,612]),'fire')
PRING=A.gmap(A.ruf_cells(1300,1356,[227,248,280,320,370,420,473,527,580]),'fire',lo=90,hi=250)
YPUFF=A.ruf_cells(369,424,[0,22,52,100,152,206,257,307,365])
RSE1=A.cfx('explosions','RSE1',list('ABCDEFGHIJKLMNOPQRSTUVWX'))
RSE0=A.cfx('explosions','RSE0',list('ABCDEFGHIJKLMNOPQRSTUVWXYZ'))
STREAK=A.gmap(A.cfx('explosions','RSE3',list('DEF')),'fire')
WSTREAK=A.cfx('sparks','RSS4',['A'])[0]
GLOW=A.cfx('sparks','RSS1',['A'])[0]
BURST=A.cfx('sparks','RSS2',['A','B'])
RSI3=A.cfx('fire','RSI3',list('ABCDEFGH'))
RSI0=A.cfx('fire','RSI0',list('abcdefghijklmnopqrs'))
RSI8=A.cfx('fire','RSI8',list('ABCDEFGHIJKLMNOP'))
RSK5=A.gmap(A.cfx('smoke','RSK5',list('ABCDEFGH')),'smoke')
RSK8L=A.gmap(A.cfx('smoke','RSK8',list('ABCDEFGHIJKLMNOP')),'smokelt')
RSK0=A.cfx('smoke','RSK0',list('ABCDEFGHIJKLMNOPQ'))
RSK8=A.gmap(A.cfx('smoke','RSK8',list('ABCDEFGHIJKLMNOP')),'smoke')
RSK7=A.gmap(A.cfx('smoke','RSK7',list('ABCDEFGHIJKLMNOPQR')),'smoke')
def light_curve(pts):
    def f(t):
        import numpy as np
        xs=[p[0] for p in pts]; ys=[p[1] for p in pts]; return float(np.interp(t,xs,ys,left=0,right=0))
    return f
# ================= A1 SNAP: small barrel, tight & snappy =================
def A1():
    r=random.Random(11); L=fx.barrel_layers(T0); S=[]
    T=POS['T']; M=(BX+10,POS['M'][1])
    t=T0   # E1 bottom: 2-tic white silhouette (Reactorcore ball) sitting on the floor, flat yellow ring skids out, white streak
    L+=[Layer([(A.white(RC3[5]),2)],t,(BX,FY+4),scale=3.4,anchor='b',name='E1 white sil'),
        Layer(strip(YRING[1:],[1,1,1,2,2,2,2]),t+1,(BX,FY),size=110,squash=0.28,grow=0.7,fade=0.55,floor=True,name='E1 floor ring'),
        Layer([(WSTREAK,4)],t,(BX,FY-1),scale=0.9,fade=0.2,floor=True,name='E1 streak')]
    t=T0+1 # E2 mid, offset right: Reactorcore ring-flash fireball, random roll, 1 tic/frame
    L+=[Layer(strip(RCRING[2:],1),t,M,scale=2.0,rot=r.randrange(360),name='E2 rc ring')]
    t=T0+2 # E3 top: Reactorcore yellow-brown fireball, random roll; embers thrown up
    L+=[Layer(strip(RC4[2:],[1,1,1,1,1,1,1,1,2,2,2,2,2,2]),t,(BX-4,T[1]-4),scale=2.8,rot=r.randrange(360),name='E3 rc4 fireball')]
    S+=[Sparks(t,T,n=10,over=5,spd=(3.5,6),cone=90,life=(9,14),seed=3,size=7)]
    L+=[Layer(strip(RSK8L[3:],2),T0+10,(BX+2,T[1]-14),scale=1.4,add=False,alpha=0.9,vel=(0,-0.7),fadein=3,fade=0.45,z=-1,name='smoke')]
    return L,S,light_curve([(T0-1,0),(T0,1.3),(T0+4,0.9),(T0+14,0.2),(T0+22,0)])
# ================= A2 HEAVY: huge, heavy, slow burn =================
def A2():
    r=random.Random(23); L=fx.barrel_layers(T0); S=[]
    T=POS['T']; M=(BX-14,POS['M'][1]-6)
    DM=A.circ(DOMES[1:])
    t=T0   # E1 bottom: white dome silhouette 2 tics -> RS fire dome sat on the floor; flat fire ring; floor streaks; base glow
    L+=[Layer([(A.white(RSI0[2]),2)]+strip(RSI0[2:],[1,1,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3]),t,(BX,FY+3),scale=3.4,anchor='b',fade=0.8,name='E1 RSI0 fire dome'),
        Layer([(GLOW,10)],t,(BX,FY-10),size=240,fade=0.1,name='E1 glow'),
        Layer(strip(F2RING,[14]),t+3,(BX,FY),size=130,squash=0.26,grow=1.3,fade=0.35,floor=True,name='E1 floor ring'),
        Layer(strip(STREAK,[2,2,3]),t,(BX,FY-1),scale=1.6,floor=True,fade=0.5,name='E1 fire streak'),
        Layer([(WSTREAK,5)],t,(BX,FY),scale=1.6,fade=0.3,floor=True,name='E1 white streak')]
    t=T0+1 # E2 mid offset left: fx_sheet_2 big circular blast (rounded) as a short flash, then RS fat fireball RSE1, random roll
    L+=[Layer(strip(DM,[1,1,1,3]),t,M,size=150,gain=0.75,fade=0.6,name='E2 domes flash'),
        Layer(strip(RSE1[1:],[1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3]),t+1,M,scale=2.4,rot=r.randrange(360),name='E2 RSE1 fireball')]
    t=T0+2 # E3 top: recoloured Rufaswan bubble burst + recoloured pastel rings as an upright fire cap; 14 sparks up over 7 tics
    rot=r.randrange(360); P=(BX+6,T[1]-26)
    L+=[Layer(strip(BUB[2:],[1,1,2,2,2,2,3,3,3,3]),t,P,scale=2.4,rot=rot,name='E3 bubble burst'),
        Layer(strip(PRING[3:],[2,2,3,3,4]),t+3,P,scale=2.9,grow=0.35,fade=0.6,name='E3 fire rings')]
    S+=[Sparks(t,(BX,T[1]-10),n=14,over=7,spd=(4,7.5),cone=70,life=(14,22),seed=5,size=8)]
    S+=[Sparks(t+1,(BX,FY-6),n=10,over=5,spd=(3,6),cone=150,life=(10,16),seed=9,size=6,grav=0.45)]
    # heavy smoke behind the fire
    L+=[Layer(strip(RSK0[2:],3),T0+14,(BX-6,FY-80),scale=1.3,add=False,alpha=0.85,vel=(0,-0.45),fadein=8,fade=0.55,z=-1,name='smoke1'),
        Layer(strip(RSK0[4:],3),T0+20,(BX+16,FY-108),scale=1.0,add=False,alpha=0.7,vel=(0.1,-0.6),fadein=8,fade=0.5,flip=True,z=-1,name='smoke2')]
    return L,S,light_curve([(T0-1,0),(T0,1.6),(T0+6,1.3),(T0+20,0.6),(T0+40,0.15),(T0+55,0)])
# ================= A3 PILLAR: vertical fire column =================
def A3():
    r=random.Random(37); L=fx.barrel_layers(T0); S=[]
    T=POS['T']; M=(BX+13,POS['M'][1])
    t=T0   # E1 bottom: Reactorcore white ball (sheet 3 top rows) hard flash on the floor, flames lick the floor, flat yellow ring
    L+=[Layer(strip([A.white(f) for f in RC3[2:6]],[1,1,1,1]),t,(BX,FY+4),scale=2.8,anchor='b',name='E1 white ball'),
        Layer(strip(RSI3,[2,2,2,2,2,3,3,3]),t+2,(BX+4,FY+2),scale=2.0,anchor='b',name='E1 floor flames'),
        Layer(strip(RSI3,[2,2,2,2,2,3,3,3]),t+3,(BX-20,FY+2),scale=1.5,anchor='b',flip=True,name='E1 floor flames L'),
        Layer(strip(YRING[2:],[1,1,2,2,2,3]),t+1,(BX,FY),size=110,squash=0.26,grow=0.8,fade=0.5,floor=True,name='E1 floor ring'),
        Layer([(WSTREAK,3)],t,(BX,FY-1),scale=1.0,fade=0.2,floor=True,name='E1 streak')]
    t=T0+1 # E2 mid offset right: Rufaswan yellow cluster puff, random roll
    L+=[Layer(strip(YPUFF[1:],[1,1,2,2,2,2,3]),t,M,scale=1.7,rot=r.randrange(360),name='E2 yellow puff')]
    t=T0+2 # E3 top: tall stretched RS flame jet (RSI8) on the RSE0 column blast; fire ring crown rides up the column
    L+=[Layer(strip(RSE0[1:],[1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]),t,(BX-2,T[1]+40),scale=1.7,squash=1.25,anchor='b',add=False,fade=0.45,z=-1,name='E3 RSE0 column body'),
        Layer(strip(RSI8[:13]+RSI8[2:13],[1,1]+[2]*21),t,(BX,T[1]+14),scale=2.8,squash=2.0,anchor='b',fade=0.75,name='E3 RSI8 jet'),
        Layer(strip(RSI8[4:13]+RSI8[2:13],2),t+3,(BX+7,T[1]+16),scale=2.2,squash=1.8,anchor='b',flip=True,gain=0.8,fade=0.7,name='E3 RSI8 jet 2'),
        Layer(strip(FIRERING[1:],[2,2,2,2,2,3,3,3]),t+3,(BX,T[1]-30),size=80,squash=0.35,vel=(0,-4.0),acc=(0,0.12),grow=1.0,fade=0.6,name='E3 rising crown')]
    S+=[Sparks(t,(BX,T[1]-10),n=14,over=7,spd=(6,9.5),cone=26,life=(14,20),seed=8,size=7,grav=0.3)]
    L+=[Layer(strip(RSK5,3),T0+18,(BX,T[1]-20),scale=2.4,anchor='b',add=False,alpha=0.6,vel=(0,-0.5),fadein=6,fade=0.5,z=-2,name='smoke column')]
    return L,S,light_curve([(T0-1,0),(T0,1.3),(T0+5,1.0),(T0+25,0.6),(T0+45,0)])
SEQS=[('snap',A1),('heavy',A2),('pillar',A3)]
if __name__=='__main__':
    O='/tmp/fx_agentA/out'
    which=sys.argv[1:] or [n for n,_ in SEQS]
    for name,fn in SEQS:
        if name not in which: continue
        Ls,Ss,lt=fn(); fr=fx.render(Ls,Ss,light=lt)
        fx.save(fr,f'{O}/A1_{name}_full.gif'); fx.save(fr,f'{O}/A1_{name}_half.gif',slow=2)
        import pickle; [f.save(f'/tmp/fx_agentA/look/{name}_{i:03d}.png') for i,f in enumerate(fr)]
        print(name,len(fr),'blast tics',max([l.end() for l in Ls]+[s.end() for s in Ss])-T0)
