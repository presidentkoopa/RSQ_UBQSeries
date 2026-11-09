# v2 of the three barrel sequences: centred on the barrel, pixel sources only, EoS barrel-death structure.
#  tic 0      : barrel gone; main blast at z=24 (frame 1 tic, 2-tic solid silhouette, rest), random roll;
#               3 flat streak pops at the base
#  tics 3,4,5 : one child burst per tic (EoS spawns them on BOOM A,B,C) - bottom / mid / top inside the barrel footprint
#  tics 3..9  : 2 RSS0 ember bits per tic thrown up, scattered +-26 units
import sys,random
from fx_v2 import *
B_Z,M_Z,T_Z=10,24,36            # child heights (map units): bottom / mid / top, all within 12 of the main blast
def child(frames,tic,x,z,size,rng,dtic=1,eos=True,**kw):
    """EoS ExplosmChild: random roll; x-scale creeps up 1.1-1.25 per tic for 5 tics, y-scale random (kept mild)."""
    tl=dtic if isinstance(dtic,list) else [dtic]*len(frames)
    pre=None
    if eos:
        ry=rng.uniform(.7,.9); g=rng.uniform(1.04,1.08); pre=[(g**min(i,5),ry) for i in range(sum(tl))]
    return L(frames,tl,start=tic,pos=(BX+x*U,Z(z)),size=size,rot=rng.randint(0,359),presq=pre,**kw)
# ======================= #8 B1 SHOCKWAVE ("Groundbreaker") =======================
def B1(guide=False):
    rng=random.Random(8); roll=rng.randint(0,359)
    it=[
    # soot curl (Reactorcore grey puff, soot-ramped, normal blend) behind everything
    L(pick('rc_grey',range(3,11)),3,start=11,pos=(BX-1*U,Z(18)),size=50,grow=.5,ramp=R_SOOT,gain=.7,add=False,alpha=.85,vel=(0,-.9),fade=.5,fadein=4),
    L(pick('rc_grey',range(3,11)),3,start=14,pos=(BX+1*U,Z(30)),size=42,grow=.5,ramp=R_SOOT,gain=.7,add=False,alpha=.8,vel=(0,-1.1),fade=.5,fadein=4,flip=True,rot=90),
    # floor: hot shock ring running out flat (blast radius) -> dust ring -> ember ring scorched on the floor
    L(pick('rf_yring',range(1,8)),2,start=1,pos=(BX,FLOOR-1),size=60,grow=2.0,ease=2.2,squash=.22,ramp=R_SHOCK,fade=.45),
    L(pick('ruf_dust',[1,2,3,4,5]),[3,3,4,5,6],start=3,pos=(BX,FLOOR-5),size=70,grow=1.7,ease=2,squash=.38,ramp=R_DUST,add=False,alpha=.9,fade=.55),
    L(pick('rf_firering',[5,6,7,8]),[4,5,6,8],start=6,pos=(BX,FLOOR),size=96,grow=.5,squash=.24,ramp=R_EMBER,gain=2.2,bright=1.3,cool=.4,fade=.5),
    # MAIN blast z=24: upright shock sphere (Rufaswan yellow ring: ball -> ring), random roll
    main_blast(pick('rf_yring',range(8)),[1,1,1,1,1,2,2],roll,size=66,grow=.6,ease=2,ramp=R_SHOCK,gain=1.15,alpha=.95),
    # children, one per tic on BOOM A/B/C, tight on the barrel
    child(pick('rc_ring',range(3,16)),3,-2,B_Z,88,rng,dtic=[1,1,1,1,2,2,2,2,2,2,2,3,3],fade=.75),     # bottom: ring-flash fireball
    child(pick('ruf_yflash',range(3,9)),4,+2,M_Z,46,rng,dtic=[1,1,2,2,2,3],ramp=R_SHOCK,fade=.6),    # mid: flash ring
    child(pick('rc_ring',range(4,14)),5,0,T_Z,58,rng,dtic=[1,1,1,2,2,2,2,2,3,3],fade=.7,flip=True),  # top: small fireball
    Embers(3,seed=81,gain=1.0),
    ]+pops(rng,R_SHOCK,size=80,gain=1.4)
    return render(it,tail=8,guide=guide,floorlight=banded_glow(env(1.0,2,22),(255,150,60),w=round(150*U),h=round(22*U)))
# ======================= #9 B2 DIRTY / HEAVY ("Slag Column") =======================
def B2(guide=False):
    rng=random.Random(9); roll=rng.randint(0,359)
    it=[]
    # thin rising column: a chain of small soot puffs leaving the top of the blast (replaces the smooth RSK5 strip)
    for i,t0 in enumerate(range(5,30,3)):
        it.append(L(pick('rc_grey',range(2,11)),2,start=t0,pos=(BX+(1 if i%2 else -1)*U,Z(40)),size=24+i*1.5,grow=.6,
                    ramp=R_SOOT,gain=.6,add=False,alpha=.9,vel=(0,-2.4),acc=(0,.02),fadein=3,fade=.55,flip=bool(i%2)))
    it+=[
    # floor: dirt ring
    L(pick('ruf_dust',[2,3,4,5]),[3,4,5,7],start=2,pos=(BX,FLOOR-6),size=92,grow=1.0,ease=2,squash=.45,ramp=R_DUST,add=False,alpha=.95,fade=.5),
    # children: bottom = red fireball choking to smoke, sitting on the floor; mid = brown fireball; top = small brown burst
    child(pick('rc_red',range(12),'bbox'),3,0,0,56,rng,dtic=[1,1,2,2,2,2,3,3,3,4,4,5],eos=False,anchor='b',add=False,fade=.7,clip=True),
    child(pick('rc_ybrown',range(5,16)),4,+2,M_Z,62,rng,dtic=[1,1,1,1,2,2,2,2,3,3,3],add=False,fade=.6),
    child(pick('rc_ybrown',range(6,16)),5,-2,T_Z,44,rng,dtic=[1,1,1,2,2,2,2,3,3,3],add=False,fade=.6,flip=True),
    # MAIN blast z=24: Reactorcore 64px white blob -> dirty fire choking to dark smoke, random roll, solid
    main_blast(pick('rc_x10',range(3,16)),[1]*5+[2]*5+[3]*2,roll,size=100,add=False,fade=.75),
    ]
    # heavy soot billows engulfing the fire and climbing into the column (stacked, alternating sides by 1-2 units)
    for t0,z,sz,vy,sx in [(4,30,62,-2.6,0),(8,34,54,-2.3,-1.5),(11,18,60,-2.0,1.5),(16,14,66,-1.1,0)]:
        it.append(L(pick('rc_grey',range(3,12)),3,start=t0,pos=(BX+sx*U,Z(z)),size=sz,grow=.6,ramp=R_SOOT,gain=.7,add=False,
                    alpha=.93,vel=(0,vy),acc=(0,.03),fade=.5,fadein=4,rot=rng.choice([0,90,180,270])))
    it+=[
    Particles(18,1,M_Z,speed=(3.5,7.5),spread=120,life=(30,42),g=.4,col=((120,108,95),(62,56,50)),sz=2,szr=(0,2),add=False,seed=11,drag=.98,bounce=.35),
    Embers(3,seed=91,ramp_=R_DIRTY,gain=1.6),
    ]+pops(rng,R_DIRTY,size=80,gain=1.6)
    return render(it,tail=6,guide=guide,floorlight=banded_glow(env(.85,2,12),(255,120,40),w=round(140*U),h=round(20*U)))
# ======================= #10 B3 ARCADE ("Neon Crescent") =======================
def B3(guide=False):
    rng=random.Random(10); roll=rng.randint(0,359)
    it=[
    # floor: hot-pink ring + gold echo ring spreading flat
    L(pick('ruf_bubble',[3]),[14],start=2,pos=(BX,FLOOR-1),size=60,grow=2.0,ease=2.2,squash=.24,ramp=R_NEON,fade=.4),
    L(pick('rf_yring',[3,4,5,6,7]),[2,2,3,3,4],start=5,pos=(BX,FLOOR-1),size=50,grow=2.0,ease=2,squash=.24,ramp=R_GOLD,fade=.4),
    # MAIN blast z=24: Rufaswan star pop -> neon flash ring (same sheet, same texel size), random roll
    main_blast(pick('ruf_star',[2,3,4])+pick('ruf_yflash',range(3,9)),[1,1,1,1,2,2,2,3],roll,size=70,ramp=R_NEON,cool=.5,fade=.7),
    # children: two crescents opening from white balls and flying apart (pink, gold), mirrored about the barrel; neon pop on top
    L(strip('rc_cres'),[1]*6+[2]*10,start=3,pos=(BX+4*U,Z(28)),size=60,rot=30,ramp=R_NEON,cool=.7,add=False,fade=.75,vel=(1.2,-1.2)),
    L(strip('rc_cres'),[1]*6+[2]*9+[1],start=4,pos=(BX-4*U,Z(28)),size=60,rot=200,flip=True,ramp=R_GOLD,cool=.7,add=False,fade=.75,vel=(-1.2,-1.2)),
    child(pick('ruf_yflash',range(2,9)),5,0,T_Z,40,rng,dtic=[1,1,1,2,2,2,3],eos=False,ramp=R_NEON,fade=.6),
    Embers(3,seed=101,ramp_=R_NEON,gain=2.2),
    # aftermath: Rufaswan cluster ring popping into neon bubbles
    L(pick('ruf_cluster',[2,3,4]),[4,5,6],start=10,pos=(BX,Z(28)),size=100,ramp=R_NEON,cool=.4,fade=.3),
    ]+pops(rng,R_NEON,size=80,gain=1.5)
    return render(it,tail=6,guide=guide,floorlight=banded_glow(env(1.0,2,18),(255,60,170),w=round(150*U),h=round(22*U)))
SEQ={'B1_shockwave':B1,'B2_slagcolumn':B2,'B3_neoncrescent':B3}
def sheet(fr,T0,path,lo=-3,n=36,cols=6):
    sel=list(enumerate(fr))[T0+lo:T0+lo+n]
    S=Image.new('RGB',(cols*CW,((len(sel)+cols-1)//cols)*CH)); d=ImageDraw.Draw(S)
    for i,(t,f) in enumerate(sel):
        S.paste(f,((i%cols)*CW,(i//cols)*CH)); d.text(((i%cols)*CW+4,(i//cols)*CH+4),f'tic {t-T0}',fill=(255,255,0))
    S.save(path)
if __name__=='__main__':
    guide='--guide' in sys.argv
    for name in [a for a in sys.argv[1:] if not a.startswith('-')] or SEQ:
        fr,T0=SEQ[name](guide)
        if guide:
            sheet(fr,T0,f'prev/{name}_v2_guide.png')
        else:
            save_gif(fr,f'out/{name}_v2_full.gif',1); save_gif(fr,f'out/{name}_v2_half.gif',2)
            sheet(fr,T0,f'prev/{name}_v2_p0.png',lo=-12,n=36); sheet(fr,T0,f'prev/{name}_v2_p1.png',lo=24,n=36)
        print(name,'frames',len(fr),'blast at',T0,'tics after blast',len(fr)-T0)
