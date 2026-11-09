# v3 of #8 Groundbreaker and #10 Neon Crescent (#9 Slag Column is the reference and is taken from seqs_v2 unchanged).
#  #8 : every layer re-centred on the barrel line after roll/squash/clip (LC); children, soot and embers on the line;
#       soot rises straight up; ember pairs mirrored exactly; new grit + rock debris that skitters out and settles.
#  #10: purple-soot pixel smoke (rc_grey through a neon soot ramp), crescent after-image trails, mirrored secondary
#       star pops, late flicker + last pop, pink/gold debris bits that bounce, settle and twinkle.
import sys,random
from fx_v3 import *
import seqs_v2
B_Z,M_Z,T_Z=10,24,36
# ---- palettes (stepped, hard colours) ----
GRIT=[(214,198,168),(164,144,116),(128,112,92),(104,92,78),(86,76,66)]
GRIT2=[(176,158,128),(140,122,98),(112,98,82),(92,82,70),(78,70,62)]
ROCK=[(150,128,100),(116,98,80),(92,80,68),(72,64,58)]
HOTGRIT=[(255,236,170),(255,170,60),(200,90,30),(130,70,40),(100,84,70),(86,76,66)]
PINK=[(255,250,240),(255,160,215),(255,70,165),(220,36,140),(170,22,118),(130,18,100)]
GOLD=[(255,255,225),(255,226,90),(245,170,30),(200,118,14),(150,84,18)]
WHITEP=[(255,255,255),(255,200,235),(220,120,200),(170,80,170),(120,50,120)]
R_PSOOT=ramp((0,(14,6,22)),(.45,(52,20,62)),(.8,(96,40,104)),(1,(140,74,140)))   # neon soot: dark purple/magenta
R_NEONDIM=ramp((0,(20,0,30)),(.5,(90,0,80)),(.8,(170,20,120)),(1,(220,80,170)))
R_GOLDDIM=ramp((0,(20,8,0)),(.5,(100,50,0)),(.8,(170,110,10)),(1,(220,170,40)))
# ======================= #8 B1 SHOCKWAVE ("Groundbreaker") v3 =======================
def B1(guide=False):
    rng=random.Random(8); roll=rng.randint(0,359)
    it=[
    # soot curl behind everything: both on the line, rising straight up (v2: +-1 unit and a 90 deg roll pushed it right)
    LC(pick('rc_grey',range(3,11)),3,start=11,pos=(BX,Z(18)),size=50,grow=.5,ramp=R_SOOT,gain=.7,add=False,alpha=.85,vel=(0,-.9),fade=.5,fadein=4,xc='cent'),
    LC(pick('rc_grey',range(3,11)),3,start=14,pos=(BX,Z(30)),size=42,grow=.5,ramp=R_SOOT,gain=.7,add=False,alpha=.8,vel=(0,-1.1),fade=.5,fadein=4,flip=True,rot=90,xc='cent'),
    # floor rings: hot shock ring -> dust ring -> ember scorch, centred on their drawn outline every tic
    LC(pick('rf_yring',range(1,8)),2,start=1,pos=(BX,FLOOR-1),size=60,grow=2.0,ease=2.2,squash=.22,ramp=R_SHOCK,fade=.45,xc='sym'),
    LC(pick('ruf_dust',[1,2,3,4,5]),[3,3,4,5,6],start=3,pos=(BX,FLOOR-5),size=70,grow=1.7,ease=2,squash=.38,ramp=R_DUST,add=False,alpha=.9,fade=.55,xc='sym'),
    LC(pick('rf_firering',[5,6,7,8]),[4,5,6,8],start=6,pos=(BX,FLOOR),size=96,grow=.5,squash=.24,ramp=R_EMBER,gain=2.2,bright=1.3,cool=.4,fade=.5,xc='sym'),
    lc_main(pick('rf_yring',range(8)),[1,1,1,1,1,2,2],roll,size=66,grow=.6,ease=2,ramp=R_SHOCK,gain=1.15,alpha=.95),
    # children on BOOM A/B/C, now on the centre line (v2: -2/+2 units)
    lc_child(pick('rc_ring',range(3,16)),3,B_Z,88,rng,dtic=[1,1,1,1,2,2,2,2,2,2,2,3,3],fade=.75),
    lc_child(pick('ruf_yflash',range(3,9)),4,M_Z,46,rng,dtic=[1,1,2,2,2,3],ramp=R_SHOCK,fade=.6),
    lc_child(pick('rc_ring',range(4,14)),5,T_Z,58,rng,dtic=[1,1,1,2,2,2,2,2,3,3],fade=.7,flip=True),
    EmbersC(3,seed=81,gain=1.0),
    # grit: low, fast, flat throws that skitter along the floor with the shock ring; a few bits start hot from the blast
    Debris(4,n=30,seed=801,z0=(1,6),x0=(22,32),speed=(1.3,4.3),spread=(58,84),grav=.8,bounce=(.15,.3),friction=.72,
           palettes=[(5,GRIT),(4,GRIT2),(2,HOTGRIT)],cool=(4,6),shapes=('dot','dot','bar','sq','vbar'),hold=(16,30),depth=(0,14),spawn=.34,exact=True,mirror_shape=True,until=40),
    # rock chunks: thrown higher, heavier, land later and closer
    Debris(7,n=8,seed=802,z0=(12,24),x0=(16,24),speed=(4,6.5),spread=(18,48),grav=.9,bounce=(.2,.3),friction=.5,
           palettes=[(1,ROCK)],jit=.03,cool=(6,8),shapes=('chunk','tri','slab','L'),hold=(14,22),depth=(2,10),spawn=.5,exact=True,mirror_shape=True,until=36),
    ]+lc_pops(rng,R_SHOCK,size=80,gain=1.4)
    return render3(it,tail=8,guide=guide,floorlight=banded_glow(env(1.0,2,22),(255,150,60),w=round(150*U),h=round(22*U)))
# ======================= #10 B3 ARCADE ("Neon Crescent") v3 =======================
def flicker(pat,n): return [pat[i%len(pat)] for i in range(n)]
def B3(guide=False):
    rng=random.Random(10); roll=rng.randint(0,359)
    it=[]
    # neon soot (behind everything): blocky rc_grey puffs through a dark purple/magenta ramp, rising straight up the line,
    # a mirrored pair drifting out from the crescents, and a late column
    for t0,z,sz,vy,dx,vx in [(6,26,46,-1.3,0,0),(9,30,34,-1.0,-10,-.25),(9,30,34,-1.0,10,.25),(13,40,52,-1.2,0,0),(19,46,44,-1.0,0,0)]:
        it.append(LC(pick('rc_grey',range(3,12)),3,start=t0,pos=(BX+dx*U,Z(z)),size=sz,grow=.6,ramp=R_PSOOT,gain=.75,add=False,
                     alpha=.9,vel=(vx,vy),fadein=3,fade=.55,flip=dx<0,rot=rng.choice([0,90,180,270]) if dx==0 else 0,xc='cent'))
    it+=[
    LC(pick('ruf_bubble',[3]),[14],start=2,pos=(BX,FLOOR-1),size=60,grow=2.0,ease=2.2,squash=.24,ramp=R_NEON,fade=.4,xc='bbox'),
    LC(pick('rf_yring',[3,4,5,6,7]),[2,2,3,3,4],start=5,pos=(BX,FLOOR-1),size=50,grow=2.0,ease=2,squash=.24,ramp=R_GOLD,fade=.4,xc='bbox'),
    lc_main(pick('ruf_star',[2,3,4])+pick('ruf_yflash',range(3,9)),[1,1,1,1,2,2,2,3],roll,size=70,ramp=R_NEON,cool=.5,fade=.7),
    ]
    # crescents flying apart, mirrored, each with two solid after-images (dim pink / dim gold) lagging 2 and 4 tics
    for sgn,rot,flip,rp,rd,st in [(1,30,False,R_NEON,R_NEONDIM,3),(-1,200,True,R_GOLD,R_GOLDDIM,4)]:
        tl=[1]*6+[2]*10 if sgn>0 else [1]*6+[2]*9+[1]
        for lag,al in [(4,.55),(2,.8)]:
            it.append(LC(strip('rc_cres'),tl,start=st+lag,pos=(BX+sgn*4*U,Z(28)),size=60,rot=rot,flip=flip,ramp=rd,gain=.8,
                         add=False,alpha=al,fade=.5,vel=(sgn*1.2,-1.2),xc='mix'))
        it.append(LC(strip('rc_cres'),tl,start=st,pos=(BX+sgn*4*U,Z(28)),size=60,rot=rot,flip=flip,ramp=rp,cool=.7,add=False,fade=.75,
                     vel=(sgn*1.2,-1.2),xc='mix'))
    it+=[
    lc_child(pick('ruf_yflash',range(2,9)),5,T_Z,40,rng,dtic=[1,1,1,2,2,2,3],eos=False,ramp=R_NEON,fade=.6),
    EmbersC(3,seed=101,ramp_=R_NEON,gain=2.2),
    # aftermath cluster ring popping into neon bubbles, now with an arcade flicker as it dies
    LC(pick('ruf_cluster',[2,3,4]),[4,5,7],start=10,pos=(BX,Z(28)),size=100,ramp=R_NEON,cool=.4,fade=.45,
       alist=[1]*9+flicker([1,0,1,1,0,1,0,0],8),xc='mix'),
    ]
    # secondary star pops: mirrored pairs (pink one side, gold the other, swapping), then a single late pop on the line
    for t0,dx,z,sz in [(9,27,30,34),(12,11,52,26),(16,22,20,22)]:
        sw=(t0//4)%2
        for sgn in (-1,1):
            rp=R_NEON if (sgn>0)^sw else R_GOLD
            it.append(LC(pick('ruf_star',[0,1,2,3,4]),[1,1,1,2,2],start=t0,pos=(BX+sgn*dx*U,Z(z)),size=sz,rot=rng.choice([0,45,90]),
                         ramp=rp,cool=.5,fade=.5,xc='mix'))
    it+=[
    LC(pick('ruf_star',[1,2,3,4]),[1,1,2,2],start=22,pos=(BX,Z(44)),size=30,ramp=R_NEON,fade=.4,xc='mix'),
    LC(pick('ruf_yflash',range(3,9)),[1,1,1,2,2,3],start=23,pos=(BX,Z(44)),size=34,ramp=R_GOLD,cool=.5,fade=.5,xc='mix',
       alist=[1,1,0,1,1,0,1,0,1,0]),
    # pink / gold / white bits: bouncy, cool to deep magenta / brown, twinkle once settled, blink out
    Debris(2,n=22,seed=1001,z0=(14,30),speed=(2.6,4.6),spread=(15,58),grav=.75,bounce=(.38,.5),friction=.7,
           palettes=[(5,PINK),(4,GOLD),(1,WHITEP)],cool=(3,4),shapes=('dot','sq','bar','L','vbar'),hold=(8,16),depth=(0,12),
           spawn=.5,twinkle=7,trail=1,exact=True,until=38),
    ]+lc_pops(rng,R_NEON,size=80,gain=1.5)
    # floor light: banded glow, with a stepped flicker near the end
    base=env(1.0,2,18); fl=lambda t: base(t)*(0 if t in (13,16,17,21) else 1)+(.5 if t in (22,23) else 0)
    return render3(it,tail=6,guide=guide,floorlight=banded_glow(fl,(255,60,170),w=round(150*U),h=round(22*U)))
def B2(guide=False): return seqs_v2.B2(guide)
SEQ={'B1_shockwave':B1,'B2_slagcolumn':B2,'B3_neoncrescent':B3}
def sheet(fr,T0,path,lo=-3,n=36,cols=6):
    sel=list(enumerate(fr))[T0+lo:T0+lo+n]
    S=Image.new('RGB',(cols*CW,((len(sel)+cols-1)//cols)*CH)); d=ImageDraw.Draw(S)
    for i,(t,f) in enumerate(sel):
        S.paste(f,((i%cols)*CW,(i//cols)*CH)); d.text(((i%cols)*CW+4,(i//cols)*CH+4),f'tic {t-T0}',fill=(255,255,0))
    S.save(path)
if __name__=='__main__':
    guide='--guide' in sys.argv
    names=[a for a in sys.argv[1:] if not a.startswith('-')] or ['B1_shockwave','B3_neoncrescent']
    for name in names:
        fr,T0=SEQ[name](guide)
        if guide:
            sheet(fr,T0,f'v3/{name}_v3_guide_a.png',lo=-2,n=30); sheet(fr,T0,f'v3/{name}_v3_guide_b.png',lo=28,n=30)
        else:
            save_gif(fr,f'out/{name}_v3_full.gif',1); save_gif(fr,f'out/{name}_v3_half.gif',2)
        print(name,'frames',len(fr),'blast at',T0,'tics after blast',len(fr)-T0)
