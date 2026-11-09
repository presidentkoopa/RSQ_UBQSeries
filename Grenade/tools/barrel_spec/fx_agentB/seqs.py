import sys,random
from fx import *
def env(peak=1.0,attack=1,decay=20,start=0):
    def e(t):
        t-=start
        if t<0: return 0
        if t<attack: return peak*(t+1)/attack
        return peak*max(0,1-(t-attack)/decay)**1.6
    return e
# ======================= B1 SHOCKWAVE ("Groundbreaker") =======================
def B1():
    mx,my=MID(+1)
    it=[
    # aftermath smoke first so every additive layer glows over it
    L(strip('smoke/RSK0?0.png'),2,start=12,pos=(BX-4,FLOOR-BH//2),size=64,grow=.9,ramp=R_SOOT,gain=1.7,add=False,alpha=.7,vel=(0,-1.1),fade=.45,fadein=5),
    # BOTTOM emitter, tic 0: white star silhouette (2 tics) -> flat streak on the floor -> floor shock ring -> dust ring -> ember scorch
    L(strip('explosions/RSE3?0.png')[:3],[2,1,1],start=0,pos=(BX,FLOOR-BH//3),size=110,ramp=R_SHOCK,sil=2),
    L(strip('explosions/RSE3?0.png')[3:],[2,2,3],start=3,pos=(BX,FLOOR-2),size=150,grow=.4,squash=.6,ramp=R_SHOCK,fade=.3,clip=False),
    L(pick('rf_yring',range(1,8)),2,start=1,pos=(BX,FLOOR-1),size=60,grow=2.0,ease=2.2,squash=.22,ramp=R_SHOCK,fade=.45),
    L(pick('ruf_dust',[1,2,3,4,5]),[3,3,4,5,6],start=3,pos=(BX,FLOOR-5),size=70,grow=1.7,ease=2,squash=.38,ramp=R_DUST,add=False,alpha=.9,fade=.55),
    L(strip('explosions/RSED?0.png'),[3,3,4,5,6,8],start=6,pos=(BX,FLOOR),size=70,grow=.6,squash=.24,ramp=R_EMBER,gain=2.6,bright=1.4,cool=.4,fade=.5),
    # MID emitter, tic 1, offset right: Reactorcore ring flash, rolled
    L(strip('rc_ring'),[1,1,1,1,2,2,2,2,2,2,2,2,2,2,3,3],start=1,pos=(mx,my),size=120,rot=37,fade=.75),
    # TOP emitter, tic 2: upright shock sphere + radial spark burst + 14 thrown sparks
    L(strip('rf_yring'),2,start=2,pos=TOP,size=74,grow=.7,ease=2,rot=200,ramp=R_SHOCK,alpha=.9,fade=.5),
    L(strip('sparks/RSS3?0.lmp')+strip('sparks/RSS3G0.png'),1,start=2,pos=TOP,size=110,ramp=R_GOLD,rot=15),
    Sparks(14,2,TOP,speed=(2.5,5.5),spread=150,life=(8,14),seed=3),
    ]
    return render(it,tail=8,floorlight=glow(env(1.1,2,22),(255,150,60),w=round(230*U),h=round(30*U)))
# ======================= B2 DIRTY / HEAVY ("Slag Column") =======================
def B2():
    mx,my=MID(-1)
    it=[
    # TOP emitter part 1: thin rising smoke column behind everything (RSK5 stretched wide)
    L(strip('smoke/RSK5?0.png'),3,start=5,pos=(BX+2,FLOOR-BH+8),size=170,xs=3.4,anchor='b',ramp=R_SOOT,gain=1.1,add=False,alpha=.9,vel=(0,-.6),fadein=6,fade=.55),
    # BOTTOM emitter, tic 0: ring-flash pop (2-tic white silhouette) + dirty fireball on the floor + red fireball choking to smoke + dirt ring
    L(pick('rc_ring',[1,2,3]),[2,1,1],start=0,pos=(BX,FLOOR-BH//3),size=100,sil=2),
    L(pick('rc_ybrown',range(3,12)),[1,1,2,2,2,2,3,3,3],start=1,pos=(BX,FLOOR+2),size=96,anchor='b'),
    L(strip('rc_red'),[1,1,2,2,2,2,3,3,3,4,4,5],start=2,pos=(BX+round(7*U),FLOOR+2),size=90,anchor='b',add=False,flip=True,fade=.7),
    L(pick('ruf_dust',[2,3,4,5]),[3,4,5,7],start=2,pos=(BX,FLOOR-6),size=92,grow=1.0,ease=2,squash=.45,ramp=R_DUST,add=False,alpha=.95,fade=.5),
    # MID emitter, tic 1, offset left: RS flame plume, gradient-mapped to dirty fire, choking out
    L(strip('explosions/RSE0?0.png')[2:20],[1]*6+[2]*12,start=1,pos=(mx,FLOOR-BH//4),size=104,anchor='b',ramp=R_DIRTY,gain=1.05,cool=.5,add=False,fade=.45),
    # TOP emitter part 2, tic 2: heavy soot billows that engulf the fire and climb
    L(strip('smoke/RSK0?0.png'),2,start=3,pos=(BX,TOP[1]-8),size=76,grow=.5,ramp=R_SOOT,gain=1.8,add=False,alpha=.92,vel=(0,-2.8),acc=(0,.03),fade=.5,fadein=6),
    L(strip('smoke/RSK8?0.png'),2,start=8,pos=(BX-4,TOP[1]-6),size=64,grow=.7,ramp=R_SOOT,gain=.8,add=False,vel=(.1,-2.4),fade=.45,fadein=4),
    L(strip('smoke/RSK0?0.png'),2,start=11,pos=(BX+5,FLOOR-BH//2),size=66,grow=.7,ramp=R_SOOT,gain=1.8,add=False,alpha=.92,vel=(-.05,-2.2),fade=.45,fadein=4,flip=True),
    L(strip('smoke/RSK4?0.png'),2,start=16,pos=(BX,FLOOR-BH//3),size=72,grow=.6,ramp=R_SOOT,gain=2.2,add=False,vel=(0,-1.0),fade=.5,fadein=6),
    # debris: dark chunks (engine particles) thrown out, bounce and settle; hot embers
    Sparks(18,1,(BX,FLOOR-BH//2),speed=(3.5,7.5),spread=120,life=(30,42),g=.4,col=((120,108,95),(62,56,50)),sz=2,szr=(0,2),add=False,seed=11,drag=.98,bounce=.35,trail=False),
    Sparks(12,1,(BX,FLOOR-BH//2),speed=(3,6),spread=140,life=(8,16),g=.45,col=((255,200,120),(160,50,10)),seed=7),
    ]
    return render(it,tail=6,floorlight=glow(env(.85,2,12),(255,120,40),w=round(170*U),h=round(24*U)))
# ======================= B3 ARCADE ("Neon Crescent") =======================
def B3():
    mx,my=MID(+1)
    it=[
    # BOTTOM emitter, tic 0: Rufaswan star pop (2-tic white silhouette) + flat neon floor ring + gold echo ring
    L(strip('ruf_star'),[1,1,1,2,2],start=0,pos=(BX,FLOOR-BH//3),size=66,ramp=R_NEON,sil=2,cool=.9),
    L(pick('ruf_bubble',[3]),[14],start=2,pos=(BX,FLOOR-1),size=60,grow=2.0,ease=2.2,squash=.24,ramp=R_NEON,fade=.4),
    L(pick('rf_yring',[3,4,5,6,7]),[2,2,3,3,4],start=5,pos=(BX,FLOOR-1),size=50,grow=2.0,ease=2,squash=.24,ramp=R_GOLD,fade=.4),
    # MID emitter, tic 1: two Reactorcore crescents crossing (ball -> crescent), solid, one neon pink, one gold, cooling as they thin
    L(strip('rc_cres'),[1]*6+[2]*10,start=1,pos=(mx+round(4*U),my-14),size=70,rot=30,ramp=R_NEON,cool=.8,add=False,fade=.75,vel=(.5,-1.3)),
    L(strip('rc_cres'),[1]*6+[2]*10,start=2,pos=(BX-round(12*U),my-8),size=60,rot=200,flip=True,ramp=R_GOLD,cool=.6,add=False,fade=.7,vel=(-.5,-1.1)),
    # TOP emitter, tic 2: neon flash ring + spinning gold crescents thrown up + pink sparks
    L(pick('ruf_yflash',range(3,9)),[1,2,2,2,3,3],start=2,pos=TOP,size=64,grow=.6,rot=140,ramp=R_NEON,fade=.6),
    L(strip('sparks/RSS3?0.lmp')+strip('sparks/RSS3G0.png'),1,start=3,pos=TOP,size=120,ramp=R_NEON,gain=1.3,rot=-20),
    Sparks(14,2,TOP,speed=(2.5,5),spread=160,life=(7,12),col=((255,240,255),(255,40,150)),seed=5),
    # aftermath: Rufaswan cluster ring popping into neon bubbles
    L(pick('ruf_cluster',[2,3,4]),[4,5,6],start=10,pos=(BX,FLOOR-BH*2//3),size=100,ramp=R_NEON,cool=.4,fade=.3),
    ]
    return render(it,tail=6,floorlight=glow(env(1.0,2,18),(255,60,170),w=round(220*U),h=round(30*U)))
SEQ={'B1_shockwave':B1,'B2_slagcolumn':B2,'B3_neoncrescent':B3}
if __name__=='__main__':
    for name in (sys.argv[1:] or SEQ):
        fr,T0=SEQ[name]()
        save_gif(fr,f'out/{name}_full.gif',1); save_gif(fr,f'out/{name}_half.gif',2)
        # debug strip of every frame from blast-2
        sel=list(enumerate(fr))[T0-3:]
        for part in range(0,len(sel),18):
            S=Image.new('RGB',(6*CW,3*CH)); d=ImageDraw.Draw(S)
            for i,(t,f) in enumerate(sel[part:part+18]):
                S.paste(f,((i%6)*CW,(i//6)*CH)); d.text(((i%6)*CW+4,(i//6)*CH+4),f'tic {t-T0}',fill=(255,255,0))
            S.save(f'prev/{name}_p{part//18}.png')
        print(name,len(fr),'blast at',T0)
