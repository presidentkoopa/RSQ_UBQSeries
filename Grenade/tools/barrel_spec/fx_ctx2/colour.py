"""Context 4: colour by context. Base = approved #6 Heavy (x1.0), recoloured by a brightness gradient map
(8 flat steps, white flash kept white, smoke keeps half its grey).
 (a) room: the blast takes the complement of the room's GlowInTheDark colour sampled at detonation.
 (b) kill: the blast takes the tier colour of what it killed, from the tic the kill lands (white flash stays white)."""
import sys, colorsys, numpy as np
sys.path.insert(0,'/tmp/fx_ctx2'); sys.path.insert(0,'/tmp/fx_ctx2/lib')
import ctx, crowd
from PIL import Image, ImageDraw
from debris_v3 import Debris
T0=ctx.T0; PW,PH,FY,BX=320,320,262,160
def comp(rgb):
    h,s,v=colorsys.rgb_to_hsv(*[x/255 for x in rgb]); r,g,b=colorsys.hsv_to_rgb((h+.5)%1,s,v); return (int(r*255),int(g*255),int(b*255))
def label(c,txt,col):
    im=ctx.to_img(c); d=ImageDraw.Draw(im); d.text((6,4),txt,fill=col); return np.asarray(im).astype(np.float32)/255
def room(c,G):
    """GlowInTheDark room: dark wall with flat glow bands rising off the floor, a glow trim strip, panel seams; floor lit"""
    g=np.array(G)/255
    c[:FY]=(0.04,0.04,0.05)
    for y0,y1,k in [(FY-150,FY-110,.10),(FY-110,FY-70,.18),(FY-70,FY-34,.28),(FY-34,FY,.40)]:
        c[y0:y1]=np.array((0.04,0.04,0.05))+g*k
    c[FY-156:FY-152]=g*0.85                                  # glowing trim strip
    for x in range(24,PW,64): c[FY-150:FY,x:x+2]*=0.55       # panel seams
    c[FY:]=np.array(ctx.FLOORC)+g*0.10; c[FY+8:]=np.array(ctx.FLOORC)+g*0.06
    c[FY:FY+1]=np.maximum(c[FY:FY+1],g*0.6)
def tinted(col):
    """flash tics (T0..T0+2: the 1-tic ball and the 2-tic solid silhouette) keep everything white-hot white;
    after that the white core maps to the palest tint, so the colour reads on the ball itself"""
    C,O,lt=ctx.plate('heavy'); lf=ctx.hue_ramp(col,.93); lb=ctx.hue_ramp(col,1.01)
    return [ctx.gmap(Ci,lf if t<=T0+2 else lb,smoke_keep=0.5,white=.93 if t<=T0+2 else 1.01) for t,Ci in enumerate(C)],O,lt
def room_panel(G):
    K=comp(G); C,O,lt=tinted(K); S=ctx.Scene(PW,PH,FY)
    pc=np.array(K)/255; pc=pc/pc.max()
    out=[]
    for t in range(len(C)+8):
        c=S.blank(); room(c,G)
        S.pool(c,BX+0.5,lt(t),col=tuple(pc))
        b=ctx.barrel_img(t,T0)
        if b: S.sprite(c,b,BX,FY)
        if t<len(C): S.comp(c,C[t],O[t],(ctx.PBX,ctx.PFY),BX,FY,solid=2.5)
        out.append(label(c,f'room {G} -> blast {K}',(200,200,200)))
    return out
ROOMS=[(40,255,80),(255,130,20),(150,50,255)]
def shot_room():
    P=[room_panel(G) for G in ROOMS]
    return [ctx.to_img(np.hstack([p[t] for p in P])) for t in range(len(P[0]))]
# ---------- (b) tier of the kill ----------
TIER={'Red':(6,(235,30,30),'T10'),'Blue':(3,(40,110,255),'T02')}
def kill_panel(name):
    n,col,folder=TIER[name]; W=360; bx=150
    Cb,O,lt=ctx.plate('heavy'); Ct,_,_=tinted(col); S=ctx.Scene(W,PH,FY)
    A=crowd.sc(crowd.imps.front(folder,'A'),1.25).transpose(Image.FLIP_LEFT_RIGHT); B=crowd.sc(crowd.imps.front(folder,'B'),1.25).transpose(Image.FLIP_LEFT_RIGHT)
    ix=bx+92; KILL=T0+2                                   # imp dies on tic +2; blast recoloured from then on
    pal=crowd.own_palette(A)
    bits=Debris(KILL+1,ix+0.5,FY,1.25,cscale=1/255,n=12,seed=7,z0=(18,40),x0=(2,10),speed=(3,7),spread=(15,80),grav=1.0,bounce=(.15,.25),
                friction=.4,palettes=[(2,crowd.BLOOD),(1,pal)],cool=(6,8),shapes=('sq','chunk','L','slab'),px=2,hold=(14,24),depth=(0,18),spawn=.3,exact=True,until=40)
    chunks=crowd.Chunks(KILL+1,ix,A.height*0.55,n=5,seed=3,k=1.5)
    pc=np.array(col)/255; pc=pc/pc.max(); fire=np.array((1.0,.55,.2))
    out=[]
    for t in range(len(Cb)+8):
        c=S.blank()
        S.pool(c,bx+0.5,lt(t),col=tuple(fire if t<KILL else pc))
        b=ctx.barrel_img(t,T0)
        if b: S.sprite(c,b,bx,FY)
        if t<T0+1: S.sprite(c,A if (t//8)%2==0 else B,ix,FY)
        elif t<KILL: S.sprite(c,crowd.white(A),ix,FY)
        if t<len(Cb):
            C=Ct[t] if t>=KILL else Cb[t]
            S.comp(c,C,O[t],(ctx.PBX,ctx.PFY),bx,FY)
        j=t-(KILL+1)
        if 0<=j<12:
            fi=j if j<4 else 4+(j-4)//2
            if fi<8: S.sprite(c,crowd.sc(crowd.BURST[fi],1.5),ix,FY-A.height*0.55,anchor='c')
        bits.draw(c,t); chunks.draw(S,c,t)
        out.append(label(c,f'killed: {name} (tier {n})',tuple(int(v) for v in np.array(col)*0.6+100)))
    return out
def shot_kill():
    P=[kill_panel('Red'),kill_panel('Blue')]
    return [ctx.to_img(np.hstack([p[t] for p in P])) for t in range(len(P[0]))]
if __name__=='__main__':
    which=sys.argv[1:] or ['room','kill']
    if 'room' in which:
        fr=shot_room(); ctx.save(fr,'/tmp/fx_ctx2/out/C_colour_room_full.gif'); ctx.save(fr,'/tmp/fx_ctx2/out/C_colour_room_half.gif',slow=2)
        for i,f in enumerate(fr): f.save(f'/tmp/fx_ctx2/look/room_{i:03d}.png')
    if 'kill' in which:
        fr=shot_kill(); ctx.save(fr,'/tmp/fx_ctx2/out/C_colour_kill_full.gif'); ctx.save(fr,'/tmp/fx_ctx2/out/C_colour_kill_half.gif',slow=2)
        for i,f in enumerate(fr): f.save(f'/tmp/fx_ctx2/look/kill_{i:03d}.png')
